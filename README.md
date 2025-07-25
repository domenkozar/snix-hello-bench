# Snix vs Nix Benchmark

This repository contains benchmarks comparing [snix](https://git.snix.dev/snix/snix.git) (a Nix interpreter written in Rust) with the standard Nix implementation.

## Benchmark Task

Evaluating the derivation path for the `hello` package from nixpkgs:
- Snix: `(import <nixpkgs> {}).hello.drvPath`
- Nix: `(import <nixpkgs> {}).hello`

## Results

| Command | Mean [s] | Min [s] | Max [s] | Relative |
|:---|---:|---:|---:|---:|
| `snix` | 1.107 ± 0.011 | 1.082 | 1.117 | 2.33 ± 0.05 |
| `nix-instantiate` | 0.476 ± 0.010 | 0.467 | 0.501 | 1.00 |

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
