# Snix vs Nix Benchmark

This repository contains benchmarks comparing [snix](https://git.snix.dev/snix/snix.git) (a Nix interpreter written in Rust) with the standard Nix implementation.

## Benchmark Task

Evaluating the derivation path for the `hello` package from nixpkgs:
- Snix: `(import <nixpkgs> {}).hello.drvPath`
- Nix: `(import <nixpkgs> {}).hello`

## Results

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `snix` | 992.4 ± 5.0 | 986.6 | 1000.9 | 2.52 ± 0.05 |
| `nix-instantiate` | 393.9 ± 7.4 | 384.2 | 405.0 | 1.00 |

## Performance Analysis

The flamegraph for snix is available at [snix-flamegraph.svg](snix-flamegraph.svg), which shows where time is spent during evaluation.

## Running the Benchmark

```bash
# Enter the development environment
devenv shell

# Run the benchmark
benchmark
```

The benchmark script will:
1. Clone/update nixpkgs and snix repositories
2. Build snix in release mode
3. Run hyperfine to benchmark both implementations
4. Generate a flamegraph for snix
5. Update this README with the latest results

## Environment

- Rust: via devenv
- Nix: system installation
- Tools: hyperfine, flamegraph, perf
