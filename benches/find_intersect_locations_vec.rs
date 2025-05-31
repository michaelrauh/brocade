use brocade::kernel::{find_intersect_locations_vec, find_intersect_locations, find_intersect_locations_vec_mut, find_intersect_locations_mut};
use criterion::{criterion_group, criterion_main, Criterion};
use std::hint::black_box;

fn bench_find_intersect_locations_vec(c: &mut Criterion) {
    let size = 1024;
    let l: Vec<u64> = (0..size).map(|i| if i % 2 == 0 { !0 } else { 0 }).collect();
    let r: Vec<u64> = (0..size).map(|i| if i % 3 == 0 { !0 } else { 0 }).collect();
    c.bench_function("find_intersect_locations_vec", |b| {
        b.iter(|| {
            let _ = find_intersect_locations_vec(black_box(&l), black_box(&r));
        });
    });
}

fn bench_find_intersect_locations_vec_mut(c: &mut Criterion) {
    let size = 1024;
    let l: Vec<u64> = (0..size).map(|i| if i % 2 == 0 { !0 } else { 0 }).collect();
    let r: Vec<u64> = (0..size).map(|i| if i % 3 == 0 { !0 } else { 0 }).collect();
    let mut result = Vec::with_capacity(size << 2);
    c.bench_function("find_intersect_locations_vec_mut", |b| {
        b.iter(|| {
            find_intersect_locations_vec_mut(black_box(&l), black_box(&r), black_box(&mut result));
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
            let _ = find_intersect_locations(black_box(&[&l, &r]), black_box(&forbidden));
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
            find_intersect_locations_mut(black_box(&[&l, &r]), black_box(&forbidden), black_box(&mut result));
        });
    });
}

fn bench_find_intersect_locations_single_array(c: &mut Criterion) {
    let size = 1024;
    let arr: Vec<u64> = (0..size).map(|i| if i % 2 == 0 { !0 } else { 0 }).collect();
    let forbidden: Vec<u64> = vec![0; size]; // No forbidden bits
    c.bench_function("find_intersect_locations_single_array", |b| {
        b.iter(|| {
            let _ = find_intersect_locations(black_box(&[&arr]), black_box(&forbidden));
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
            find_intersect_locations_mut(black_box(&[&arr]), black_box(&forbidden), black_box(&mut result));
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
            let _ = find_intersect_locations(black_box(&[&l, &r, &s]), black_box(&forbidden));
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
            find_intersect_locations_mut(black_box(&[&l, &r, &s]), black_box(&forbidden), black_box(&mut result));
        });
    });
}

// Test reusing vector vs allocating new ones across multiple calls
fn bench_multiple_calls_immutable(c: &mut Criterion) {
    let size = 512; // Smaller size for multiple calls
    let l: Vec<u64> = (0..size).map(|i| if i % 2 == 0 { !0 } else { 0 }).collect();
    let r: Vec<u64> = (0..size).map(|i| if i % 3 == 0 { !0 } else { 0 }).collect();
    let s: Vec<u64> = (0..size).map(|i| if i % 5 == 0 { !0 } else { 0 }).collect();
    
    c.bench_function("multiple_calls_immutable", |b| {
        b.iter(|| {
            // Simulate multiple operations that need intersection results
            let _result1 = find_intersect_locations_vec(black_box(&l), black_box(&r));
            let _result2 = find_intersect_locations_vec(black_box(&r), black_box(&s));
            let _result3 = find_intersect_locations_vec(black_box(&l), black_box(&s));
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
            find_intersect_locations_vec_mut(black_box(&l), black_box(&r), black_box(&mut result));
            // Vector is cleared automatically by the function
            find_intersect_locations_vec_mut(black_box(&r), black_box(&s), black_box(&mut result));
            find_intersect_locations_vec_mut(black_box(&l), black_box(&s), black_box(&mut result));
        });
    });
}

criterion_group!(
    benches, 
    bench_find_intersect_locations_vec,
    bench_find_intersect_locations_vec_mut,
    bench_find_intersect_locations,
    bench_find_intersect_locations_mut,
    bench_find_intersect_locations_single_array,
    bench_find_intersect_locations_single_array_mut,
    bench_find_intersect_locations_three_arrays,
    bench_find_intersect_locations_three_arrays_mut,
    bench_multiple_calls_immutable,
    bench_multiple_calls_mutable_reuse
);
criterion_main!(benches);
