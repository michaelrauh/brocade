use std::collections::HashMap;

/// Empty struct to hold bit intersection operations
pub struct BitIntersector;

impl BitIntersector {
    /// Extract all set bit positions from a u64, given a base offset
    fn extract_bit_positions(combined: u64, bit_base: usize, output: &mut impl Extend<usize>) {
        let mut bits = combined;
        while bits != 0 {
            let tz = bits.trailing_zeros() as usize;
            output.extend(std::iter::once(bit_base + tz));
            bits &= bits - 1; // Clear the lowest set bit
        }
    }

    /// Process intersections for a single u64 pair and collect indices
    fn process_u64_intersection(left: u64, right: u64, bit_base: usize, output: &mut impl Extend<usize>) {
        let combined = left & right;
        if combined != 0 {
            Self::extract_bit_positions(combined, bit_base, output);
        }
    }

    /// Find intersections between two u64 arrays, mutating the provided result vector
    pub fn find_intersect_locations_vec_mut(l: &[u64], r: &[u64], locations: &mut Vec<usize>) {
        locations.clear();
        
        for (i, (&left, &right)) in l.iter().zip(r.iter()).enumerate() {
            Self::process_u64_intersection(left, right, i << 6, locations);
        }
    }

    /// Find intersections among multiple arrays, mutating the provided result vector
    pub fn find_intersect_locations_mut(arrays: &[&[u64]], forbidden: &[u64], result: &mut Vec<usize>) {
        result.clear();
        
        // Handle empty input
        if arrays.is_empty() {
            return;
        }
        
        // All arrays should have the same length
        let len = arrays[0].len();
        debug_assert!(arrays.iter().all(|arr| arr.len() == len), "All arrays must have the same length");
        debug_assert_eq!(forbidden.len(), len, "Forbidden vector must have the same length as other arrays");
        
        // Handle single array case more efficiently
        if arrays.len() == 1 {
            let arr = arrays[0];
            for i in 0..len {
                let mut bits = arr[i];
                // Apply forbidden mask
                bits &= !forbidden[i]; // Clear forbidden bits
                Self::extract_bit_positions(bits, i << 6, result);
            }
            return;
        }
        
        // Handle two arrays case using existing optimized function (modified for forbidden)
        if arrays.len() == 2 {
            for (i, (&left, &right)) in arrays[0].iter().zip(arrays[1].iter()).enumerate() {
                let mut combined = left & right;
                // Apply forbidden mask
                combined &= !forbidden[i]; // Clear forbidden bits
                if combined != 0 {
                    Self::extract_bit_positions(combined, i << 6, result);
                }
            }
            return;
        }
        
        // Multiple arrays - compute intersection directly
        for i in 0..len {
            // Start with first array's value
            let mut combined = arrays[0][i];
            
            // Intersect with remaining arrays
            for j in 1..arrays.len() {
                combined &= arrays[j][i];
                if combined == 0 {
                    break; // Early exit if intersection becomes empty
                }
            }
            
            // Apply forbidden mask
            combined &= !forbidden[i]; // Clear forbidden bits
            
            // Process the intersection bits
            if combined != 0 {
                Self::extract_bit_positions(combined, i << 6, result);
            }
        }
    }

    /// Original function that allocates a new vector
    pub fn find_intersect_locations(arrays: &[&[u64]], forbidden: &[u64]) -> Vec<usize> {
        let mut result = Vec::new();
        Self::find_intersect_locations_mut(arrays, forbidden, &mut result);
        result
    }
}

/// String interner that maps phrases to bitsets for efficient intersection operations
pub struct StringInterner {
    word_to_index: HashMap<String, usize>,           // word -> vocab index
    prefix_bitsets: HashMap<Vec<usize>, Vec<u64>>,   // prefix indices -> bitset
}

impl StringInterner {
    /// Create a new empty StringInterner
    pub fn new() -> Self {
        Self {
            word_to_index: HashMap::new(),
            prefix_bitsets: HashMap::new(),
        }
    }

    /// Get the current vocabulary size
    pub fn vocab_size(&self) -> usize {
        self.word_to_index.len()
    }

    /// Calculate the number of u64s needed for bitsets of current vocabulary size
    fn bitset_u64_len(&self) -> usize {
        let vocab_size = self.vocab_size();
        if vocab_size == 0 {
            0
        } else {
            (vocab_size + 63) / 64  // Ceiling division
        }
    }

    /// Set a single bit in a bitset at the specified index
    fn set_bit(bitset: &mut Vec<u64>, bit_index: usize) {
        let u64_index = bit_index / 64;
        let bit_pos = bit_index % 64;
        
        // Set the bit
        bitset[u64_index] |= 1u64 << bit_pos;
    }

    /// Grow all existing bitsets to accommodate additional words in vocabulary
    fn grow_bitsets(&mut self, additional_words: usize) {
        if additional_words == 0 {
            return;
        }
        
        let new_vocab_size = self.vocab_size() + additional_words;
        let new_u64_len = (new_vocab_size + 63) / 64; // Ceiling division
        
        // Resize all existing bitsets
        for bitset in self.prefix_bitsets.values_mut() {
            bitset.resize(new_u64_len, 0);
        }
    }

    /// Add new words to vocabulary and return count of words added
    fn ensure_words(&mut self, words: &[String]) -> usize {
        let mut added_count = 0;
        
        for word in words {
            if !self.word_to_index.contains_key(word) {
                let new_index = self.word_to_index.len();
                self.word_to_index.insert(word.clone(), new_index);
                added_count += 1;
            }
        }
        
        added_count
    }

    /// Convert string slice to index vector, returning None if any word is not in vocabulary
    fn strings_to_indices(&self, strings: &[String]) -> Option<Vec<usize>> {
        strings.iter()
            .map(|s| self.word_to_index.get(s).copied())
            .collect()
    }

    /// Process a batch of phrases, adding new vocabulary and updating bitsets
    pub fn add_batch(&mut self, phrases: Vec<Vec<String>>) {
        if phrases.is_empty() {
            return;
        }
        
        // Validate all phrases have length >= 2
        debug_assert!(phrases.iter().all(|p| p.len() >= 2), "All phrases must have length >= 2");
        
        // Extract all unique words from all phrases
        let mut all_words = std::collections::HashSet::new();
        for phrase in &phrases {
            for word in phrase {
                all_words.insert(word.clone());
            }
        }
        let unique_words: Vec<String> = all_words.into_iter().collect();
        
        // Add new words to vocabulary
        let words_added = self.ensure_words(&unique_words);
        
        // Grow existing bitsets if we added new words
        if words_added > 0 {
            self.grow_bitsets(words_added);
        }
        
        // Process each phrase
        for phrase in phrases {
            let len = phrase.len();
            let prefix = &phrase[..len - 1];
            let last_word = &phrase[len - 1];
            
            // Convert prefix to indices
            let prefix_indices = self.strings_to_indices(prefix)
                .expect("All words should be in vocabulary after ensure_words");
            
            // Get last word index
            let last_word_index = self.word_to_index[last_word];
            
            // Get or create bitset for this prefix
            let bitset_len = self.bitset_u64_len();
            let bitset = self.prefix_bitsets.entry(prefix_indices)
                .or_insert_with(|| vec![0u64; bitset_len]);
            
            // Set the bit for the last word
            Self::set_bit(bitset, last_word_index);
        }
    }

    /// Get the bitset for a given prefix, returning None if prefix not found
    pub fn get_bitset(&self, prefix: &[String]) -> Option<&[u64]> {
        // Convert prefix strings to indices
        let prefix_indices = self.strings_to_indices(prefix)?;
        
        // HashMap lookup for bitset
        self.prefix_bitsets.get(&prefix_indices).map(|v| v.as_slice())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn find_intersect_locations_to_indices() {
        // l and r have two u64s each
        let l = vec![
            0b0000_0000_0000_0000_0000_0000_0000_1000u64, // bit 3 set
            0b0000_0000_0000_0000_0000_0000_0001_0000u64, // bit 68 set (4th bit in 2nd u64)
        ];
        let r = vec![
            0b0000_0000_0000_0000_0000_0000_0000_1000u64, // bit 3 set
            0b0000_0000_0000_0000_0000_0000_0001_0000u64, // bit 68 set
        ];
        let forbidden = vec![0u64; 2]; // No forbidden bits
        
        // Intersections at bit 3 (global 3) and bit 4 of 2nd u64 (global 64+4=68)
        let result = BitIntersector::find_intersect_locations(&[&l, &r], &forbidden);
        assert_eq!(result, vec![3, 68]);
    }

    #[test]
    fn find_intersect_locations_empty_arrays() {
        let forbidden: Vec<u64> = vec![];
        let result = BitIntersector::find_intersect_locations(&[], &forbidden);
        assert_eq!(result, Vec::<usize>::new());
    }

    #[test]
    fn find_intersect_locations_single_array() {
        let arr = vec![
            0b0000_0000_0000_0000_0000_0000_0000_1010u64, // bits 1 and 3 set
            0b0000_0000_0000_0000_0000_0000_0001_0000u64, // bit 68 set
        ];
        let forbidden = vec![0u64; 2]; // No forbidden bits
        
        // With single array, all set bits should be returned
        let result = BitIntersector::find_intersect_locations(&[&arr], &forbidden);
        assert_eq!(result, vec![1, 3, 68]);
    }

    #[test]
    fn find_intersect_locations_three_arrays() {
        let arr1 = vec![
            0b0000_0000_0000_0000_0000_0000_0000_1110u64, // bits 1, 2, 3 set
        ];
        let arr2 = vec![
            0b0000_0000_0000_0000_0000_0000_0000_1010u64, // bits 1, 3 set
        ];
        let arr3 = vec![
            0b0000_0000_0000_0000_0000_0000_0000_1000u64, // bit 3 set
        ];
        let forbidden = vec![0u64; 1]; // No forbidden bits
        
        // Only bit 3 is set in all three arrays
        let result = BitIntersector::find_intersect_locations(&[&arr1, &arr2, &arr3], &forbidden);
        assert_eq!(result, vec![3]);
    }

    #[test]
    fn find_intersect_locations_no_intersection() {
        let arr1 = vec![
            0b0000_0000_0000_0000_0000_0000_0000_0001u64, // bit 0 set
        ];
        let arr2 = vec![
            0b0000_0000_0000_0000_0000_0000_0000_0010u64, // bit 1 set
        ];
        let forbidden = vec![0u64; 1]; // No forbidden bits
        
        // No intersection between the arrays
        let result = BitIntersector::find_intersect_locations(&[&arr1, &arr2], &forbidden);
        assert_eq!(result, Vec::<usize>::new());
    }

    #[test]
    fn find_intersect_locations_with_forbidden() {
        let arr1 = vec![
            0b0000_0000_0000_0000_0000_0000_0000_1110u64, // bits 1, 2, 3 set
        ];
        let arr2 = vec![
            0b0000_0000_0000_0000_0000_0000_0000_1010u64, // bits 1, 3 set
        ];
        let forbidden = vec![
            0b0000_0000_0000_0000_0000_0000_0000_1000u64, // bit 3 forbidden
        ];
        
        // Only bit 1 is set in both arrays and not forbidden
        let result = BitIntersector::find_intersect_locations(&[&arr1, &arr2], &forbidden);
        assert_eq!(result, vec![1]);
    }

    #[test]
    fn string_interner_basic_functionality() {
        let mut interner = StringInterner::new();
        assert_eq!(interner.vocab_size(), 0);
        
        // Add some phrases
        let phrases = vec![
            vec!["the".to_string(), "cat".to_string()],
            vec!["the".to_string(), "dog".to_string()],
            vec!["big".to_string(), "cat".to_string()],
        ];
        
        interner.add_batch(phrases);
        assert_eq!(interner.vocab_size(), 4); // "the", "cat", "dog", "big"
        
        // Test bitset retrieval
        let prefix = vec!["the".to_string()];
        let bitset = interner.get_bitset(&prefix).unwrap();
        assert!(!bitset.is_empty());
        
        // Test non-existent prefix
        let missing_prefix = vec!["missing".to_string()];
        assert!(interner.get_bitset(&missing_prefix).is_none());
    }

    #[test]
    fn string_interner_bit_setting() {
        let mut interner = StringInterner::new();
        
        let phrases = vec![
            vec!["quick".to_string(), "brown".to_string()],
            vec!["quick".to_string(), "fox".to_string()],
        ];
        
        interner.add_batch(phrases);
        
        // Get bitset for prefix "quick"
        let prefix = vec!["quick".to_string()];
        let bitset = interner.get_bitset(&prefix).unwrap();
        
        // Should have bits set for "brown" and "fox"
        // Exact bit positions depend on word indexing order, but bitset should not be all zeros
        assert!(bitset.iter().any(|&bits| bits != 0));
    }

    #[test]
    fn string_interner_vocabulary_growth() {
        let mut interner = StringInterner::new();
        
        // First batch
        let batch1 = vec![
            vec!["the".to_string(), "cat".to_string()],
        ];
        interner.add_batch(batch1);
        let initial_vocab_size = interner.vocab_size();
        
        // Second batch with new words
        let batch2 = vec![
            vec!["the".to_string(), "dog".to_string()], // "dog" is new
            vec!["big".to_string(), "cat".to_string()], // "big" is new
        ];
        interner.add_batch(batch2);
        
        assert!(interner.vocab_size() > initial_vocab_size);
        
        // All prefixes should still be accessible
        assert!(interner.get_bitset(&vec!["the".to_string()]).is_some());
        assert!(interner.get_bitset(&vec!["big".to_string()]).is_some());
    }

    #[test]
    fn string_interner_integration_with_bit_intersector() {
        let mut interner = StringInterner::new();
        
        let phrases = vec![
            vec!["the".to_string(), "quick".to_string(), "brown".to_string()],
            vec!["the".to_string(), "quick".to_string(), "fox".to_string()],
            vec!["a".to_string(), "quick".to_string(), "brown".to_string()],
        ];
        
        interner.add_batch(phrases);
        
        // Get bitsets for different prefixes
        let prefix1 = vec!["the".to_string(), "quick".to_string()];
        let prefix2 = vec!["a".to_string(), "quick".to_string()];
        
        let bitset1 = interner.get_bitset(&prefix1).unwrap();
        let bitset2 = interner.get_bitset(&prefix2).unwrap();
        
        // Use BitIntersector to find intersections
        let forbidden = vec![0u64; bitset1.len()];
        let intersections = BitIntersector::find_intersect_locations(&[bitset1, bitset2], &forbidden);
        
        // Should find intersection where both prefixes lead to "brown"
        assert!(!intersections.is_empty());
    }
}

