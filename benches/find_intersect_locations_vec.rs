use brocade::kernel::{BitIntersector, StringInterner};
use criterion::{criterion_group, criterion_main, Criterion};
use std::hint::black_box;

fn bench_find_intersect_locations_vec_mut(c: &mut Criterion) {
    let size = 1024;
    let l: Vec<u64> = (0..size).map(|i| if i % 2 == 0 { !0 } else { 0 }).collect();
    let r: Vec<u64> = (0..size).map(|i| if i % 3 == 0 { !0 } else { 0 }).collect();
    let mut result = Vec::with_capacity(size << 2);
    c.bench_function("find_intersect_locations_vec_mut", |b| {
        b.iter(|| {
            BitIntersector::find_intersect_locations_vec_mut(black_box(&l), black_box(&r), black_box(&mut result));
        });
    });
}

fn bench_find_intersect_locations(c: &mut Criterion) {
    let size = 1024;
    let l: Vec<u64> = (0..size).map(|i| if i % 2 == 0 { !0 } else { 0 }).collect();
    let r: Vec<u64> = (0..size).map(|i| if i % 3 == 0 { !0 } else { 0 }).collect();
    let forbidden: Vec<u64> = vec![0; size]; // No forbidden bits
    c.bench_function("find_intersect_locations", |b| {
        b.iter(|| {
            let _ = BitIntersector::find_intersect_locations(black_box(&[&l, &r]), black_box(&forbidden));
        });
    });
}

fn bench_find_intersect_locations_mut(c: &mut Criterion) {
    let size = 1024;
    let l: Vec<u64> = (0..size).map(|i| if i % 2 == 0 { !0 } else { 0 }).collect();
    let r: Vec<u64> = (0..size).map(|i| if i % 3 == 0 { !0 } else { 0 }).collect();
    let forbidden: Vec<u64> = vec![0; size]; // No forbidden bits
    let mut result = Vec::with_capacity(size << 2);
    c.bench_function("find_intersect_locations_mut", |b| {
        b.iter(|| {
            BitIntersector::find_intersect_locations_mut(black_box(&[&l, &r]), black_box(&forbidden), black_box(&mut result));
        });
    });
}

fn bench_find_intersect_locations_single_array(c: &mut Criterion) {
    let size = 1024;
    let arr: Vec<u64> = (0..size).map(|i| if i % 2 == 0 { !0 } else { 0 }).collect();
    let forbidden: Vec<u64> = vec![0; size]; // No forbidden bits
    c.bench_function("find_intersect_locations_single_array", |b| {
        b.iter(|| {
            let _ = BitIntersector::find_intersect_locations(black_box(&[&arr]), black_box(&forbidden));
        });
    });
}

fn bench_find_intersect_locations_single_array_mut(c: &mut Criterion) {
    let size = 1024;
    let arr: Vec<u64> = (0..size).map(|i| if i % 2 == 0 { !0 } else { 0 }).collect();
    let forbidden: Vec<u64> = vec![0; size]; // No forbidden bits
    let mut result = Vec::with_capacity(size << 2);
    c.bench_function("find_intersect_locations_single_array_mut", |b| {
        b.iter(|| {
            BitIntersector::find_intersect_locations_mut(black_box(&[&arr]), black_box(&forbidden), black_box(&mut result));
        });
    });
}

fn bench_find_intersect_locations_three_arrays(c: &mut Criterion) {
    let size = 1024;
    let l: Vec<u64> = (0..size).map(|i| if i % 2 == 0 { !0 } else { 0 }).collect();
    let r: Vec<u64> = (0..size).map(|i| if i % 3 == 0 { !0 } else { 0 }).collect();
    let s: Vec<u64> = (0..size).map(|i| if i % 5 == 0 { !0 } else { 0 }).collect();
    let forbidden: Vec<u64> = vec![0; size]; // No forbidden bits
    c.bench_function("find_intersect_locations_three_arrays", |b| {
        b.iter(|| {
            let _ = BitIntersector::find_intersect_locations(black_box(&[&l, &r, &s]), black_box(&forbidden));
        });
    });
}

fn bench_find_intersect_locations_three_arrays_mut(c: &mut Criterion) {
    let size = 1024;
    let l: Vec<u64> = (0..size).map(|i| if i % 2 == 0 { !0 } else { 0 }).collect();
    let r: Vec<u64> = (0..size).map(|i| if i % 3 == 0 { !0 } else { 0 }).collect();
    let s: Vec<u64> = (0..size).map(|i| if i % 5 == 0 { !0 } else { 0 }).collect();
    let forbidden: Vec<u64> = vec![0; size]; // No forbidden bits
    let mut result = Vec::with_capacity(size << 2);
    c.bench_function("find_intersect_locations_three_arrays_mut", |b| {
        b.iter(|| {
            BitIntersector::find_intersect_locations_mut(black_box(&[&l, &r, &s]), black_box(&forbidden), black_box(&mut result));
        });
    });
}

fn bench_multiple_calls_mutable_reuse(c: &mut Criterion) {
    let size = 512; // Smaller size for multiple calls
    let l: Vec<u64> = (0..size).map(|i| if i % 2 == 0 { !0 } else { 0 }).collect();
    let r: Vec<u64> = (0..size).map(|i| if i % 3 == 0 { !0 } else { 0 }).collect();
    let s: Vec<u64> = (0..size).map(|i| if i % 5 == 0 { !0 } else { 0 }).collect();
    let mut result = Vec::with_capacity(size << 2);
    
    c.bench_function("multiple_calls_mutable_reuse", |b| {
        b.iter(|| {
            // Simulate multiple operations reusing the same vector
            BitIntersector::find_intersect_locations_vec_mut(black_box(&l), black_box(&r), black_box(&mut result));
            // Vector is cleared automatically by the function
            BitIntersector::find_intersect_locations_vec_mut(black_box(&r), black_box(&s), black_box(&mut result));
            BitIntersector::find_intersect_locations_vec_mut(black_box(&l), black_box(&s), black_box(&mut result));
        });
    });
}

fn bench_string_interner_get_bitset_small_vocab(c: &mut Criterion) {
    let mut interner = StringInterner::new();
    
    // Create phrases with small vocabulary (100 words)
    let phrases: Vec<Vec<String>> = (0..500)
        .map(|i| vec![
            format!("word_{}", i % 10),  // prefix word (10 unique)
            format!("target_{}", i % 100), // target word (100 unique)
        ])
        .collect();
    
    interner.add_batch(phrases);
    
    // Test prefixes for lookup
    let test_prefixes: Vec<Vec<String>> = (0..10)
        .map(|i| vec![format!("word_{}", i)])
        .collect();
    
    c.bench_function("string_interner_get_bitset_small_vocab", |b| {
        b.iter(|| {
            for prefix in &test_prefixes {
                let _ = interner.get_bitset(black_box(prefix));
            }
        });
    });
}

fn bench_string_interner_get_bitset_large_vocab(c: &mut Criterion) {
    let mut interner = StringInterner::new();
    
    // Create phrases with large vocabulary (10,000 words)
    let phrases: Vec<Vec<String>> = (0..5000)
        .map(|i| vec![
            format!("prefix_{}", i % 100),  // prefix word (100 unique)
            format!("target_{}", i % 10000), // target word (10,000 unique)
        ])
        .collect();
    
    interner.add_batch(phrases);
    
    // Test prefixes for lookup
    let test_prefixes: Vec<Vec<String>> = (0..100)
        .map(|i| vec![format!("prefix_{}", i)])
        .collect();
    
    c.bench_function("string_interner_get_bitset_large_vocab", |b| {
        b.iter(|| {
            for prefix in &test_prefixes {
                let _ = interner.get_bitset(black_box(prefix));
            }
        });
    });
}

fn bench_string_interner_get_bitset_multi_word_prefix(c: &mut Criterion) {
    let mut interner = StringInterner::new();
    
    // Create phrases with multi-word prefixes
    let phrases: Vec<Vec<String>> = (0..1000)
        .map(|i| vec![
            format!("word1_{}", i % 20),
            format!("word2_{}", i % 30), 
            format!("word3_{}", i % 40),
            format!("target_{}", i % 500),
        ])
        .collect();
    
    interner.add_batch(phrases);
    
    // Test 3-word prefixes for lookup
    let test_prefixes: Vec<Vec<String>> = (0..100)
        .map(|i| vec![
            format!("word1_{}", i % 20),
            format!("word2_{}", i % 30),
            format!("word3_{}", i % 40),
        ])
        .collect();
    
    c.bench_function("string_interner_get_bitset_multi_word_prefix", |b| {
        b.iter(|| {
            for prefix in &test_prefixes {
                let _ = interner.get_bitset(black_box(prefix));
            }
        });
    });
}

fn bench_string_interner_integration_workflow(c: &mut Criterion) {
    let mut interner = StringInterner::new();
    
    // Create realistic dataset
    let phrases: Vec<Vec<String>> = (0..2000)
        .map(|i| vec![
            format!("category_{}", i % 50),
            format!("subcategory_{}", i % 200),
            format!("item_{}", i % 1000),
        ])
        .collect();
    
    interner.add_batch(phrases);
    
    // Test the full workflow: get multiple bitsets and intersect them
    // Use prefixes that we know exist based on our data generation
    let prefix1 = vec!["category_0".to_string(), "subcategory_0".to_string()];
    let prefix2 = vec!["category_1".to_string(), "subcategory_1".to_string()];
    let prefix3 = vec!["category_2".to_string(), "subcategory_2".to_string()];
    
    c.bench_function("string_interner_integration_workflow", |b| {
        b.iter(|| {
            // Get bitsets (read operations) - use if let to handle potential None values gracefully
            if let (Some(bitset1), Some(bitset2), Some(bitset3)) = (
                interner.get_bitset(black_box(&prefix1)),
                interner.get_bitset(black_box(&prefix2)),
                interner.get_bitset(black_box(&prefix3))
            ) {
                // Intersect them using BitIntersector
                let forbidden = vec![0u64; bitset1.len()];
                let _intersections = BitIntersector::find_intersect_locations(
                    black_box(&[bitset1, bitset2, bitset3]), 
                    black_box(&forbidden)
                );
            }
        });
    });
}

criterion_group!(
    benches, 
    bench_find_intersect_locations_vec_mut,
    bench_find_intersect_locations,
    bench_find_intersect_locations_mut,
    bench_find_intersect_locations_single_array,
    bench_find_intersect_locations_single_array_mut,
    bench_find_intersect_locations_three_arrays,
    bench_find_intersect_locations_three_arrays_mut,
    bench_multiple_calls_mutable_reuse,
    bench_string_interner_get_bitset_small_vocab,
    bench_string_interner_get_bitset_large_vocab,
    bench_string_interner_get_bitset_multi_word_prefix,
    bench_string_interner_integration_workflow
);
criterion_main!(benches);
