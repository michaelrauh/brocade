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
        extract_bit_positions(combined, bit_base, output);
    }
}

/// Find intersections between two u64 arrays, mutating the provided result vector
pub fn find_intersect_locations_vec_mut(l: &[u64], r: &[u64], locations: &mut Vec<usize>) {
    locations.clear();
    
    for (i, (&left, &right)) in l.iter().zip(r.iter()).enumerate() {
        process_u64_intersection(left, right, i << 6, locations);
    }
}

/// Original function that allocates a new vector
pub fn find_intersect_locations_vec(l: &[u64], r: &[u64]) -> Vec<usize> {
    let mut locations = Vec::with_capacity(l.len() << 2);
    find_intersect_locations_vec_mut(l, r, &mut locations);
    locations
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
            extract_bit_positions(bits, i << 6, result);
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
                extract_bit_positions(combined, i << 6, result);
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
            extract_bit_positions(combined, i << 6, result);
        }
    }
}

/// Original function that allocates a new vector
pub fn find_intersect_locations(arrays: &[&[u64]], forbidden: &[u64]) -> Vec<usize> {
    let mut result = Vec::new();
    find_intersect_locations_mut(arrays, forbidden, &mut result);
    result
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
        let result = find_intersect_locations(&[&l, &r], &forbidden);
        assert_eq!(result, vec![3, 68]);
    }

    #[test]
    fn find_intersect_locations_empty_arrays() {
        let forbidden: Vec<u64> = vec![];
        let result = find_intersect_locations(&[], &forbidden);
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
        let result = find_intersect_locations(&[&arr], &forbidden);
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
        let result = find_intersect_locations(&[&arr1, &arr2, &arr3], &forbidden);
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
        let result = find_intersect_locations(&[&arr1, &arr2], &forbidden);
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
        let result = find_intersect_locations(&[&arr1, &arr2], &forbidden);
        assert_eq!(result, vec![1]);
    }
}

