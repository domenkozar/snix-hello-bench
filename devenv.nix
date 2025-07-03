{ pkgs, config, ... }:

{
  packages = [ 
    pkgs.cargo
    pkgs.rustc
    pkgs.flamegraph
    pkgs.nodePackages.svgo
    pkgs.nix
    pkgs.time
    pkgs.hyperfine
    pkgs.gnuplot
    pkgs.git
    pkgs.linuxPackages_latest.perf
    pkgs.protobuf
  ];

  languages.rust.enable = true;

  env.SNIX_BUILD_SANDBOX_SHELL = "${if pkgs.stdenv.isLinux then pkgs.busybox-sandbox-shell + "/bin/busybox" else "/bin/sh"}";
  env.NIX_PATH = "nixpkgs=${config.devenv.root}/nixpkgs";

  scripts.benchmark.exec = ''
    #!/usr/bin/env bash
    set -euo pipefail

    echo "=== Snix vs Nix Benchmark ==="
    echo

    # Setup nixpkgs if needed
    if [ ! -d "nixpkgs" ]; then
      echo "Cloning nixpkgs repository..."
      git clone --depth 1 https://github.com/NixOS/nixpkgs.git nixpkgs
    else
      echo "Nixpkgs already exists"
    fi

    # Setup snix if needed
    if [ ! -d "snix" ]; then
      echo "Cloning snix repository..."
      git clone https://git.snix.dev/snix/snix.git snix
    else
      echo "Updating snix repository..."
      cd snix && git checkout canon && git pull origin canon && cd ..
    fi

    # Build snix if needed
    if [ ! -f "snix/snix/target/release/snix" ]; then
      echo "Building snix in release mode..."
      cd snix/snix
      cargo build --bin snix --release
      cd ../..
      echo "Snix built successfully"
    fi

    # Run hyperfine benchmark
    echo
    echo "Running benchmark with hyperfine..."
    hyperfine \
      --warmup 3 \
      --min-runs 10 \
      --export-json benchmark-results.json \
      --export-markdown benchmark-results.md \
      --show-output \
      --command-name "snix" \
      "./snix/snix/target/release/snix --no-warnings -E '(import <nixpkgs> {}).hello.drvPath'" \
      --command-name "nix-instantiate" \
      "nix-instantiate -E '(import <nixpkgs> {}).hello'"

    echo
    echo "Benchmark results:"
    cat benchmark-results.md

    # Generate flamegraph for snix
    echo
    echo "Generating flamegraph for snix..."
    cd snix/snix
    CARGO_PROFILE_RELEASE_DEBUG=true cargo flamegraph --bin snix --release -- --no-warnings -E '(import <nixpkgs> {}).hello.outPath'
    mv flamegraph.svg ../../snix-flamegraph.svg
    cd ../..

    echo "optimizing svg"
    svgo snix-flamegraph.svg
    
    echo
    echo "Results saved to:"
    echo "  - benchmark-results.json"
    echo "  - benchmark-results.md" 
    echo "  - snix-flamegraph.svg"

    # Generate README with results
    echo
    echo "Generating README.md..."
    cat > README.md <<EOF
# Snix vs Nix Benchmark

This repository contains benchmarks comparing [snix](https://git.snix.dev/snix/snix.git) (a Nix interpreter written in Rust) with the standard Nix implementation.

## Benchmark Task

Evaluating the derivation path for the \`hello\` package from nixpkgs:
- Snix: \`(import <nixpkgs> {}).hello.drvPath\`
- Nix: \`(import <nixpkgs> {}).hello\`

## Results

$(cat benchmark-results.md)

## Performance Analysis

The flamegraph for snix is available at [snix-flamegraph.svg](snix-flamegraph.svg), which shows where time is spent during evaluation.

## Running the Benchmark

\`\`\`bash
# Enter the development environment
devenv shell

# Run the benchmark
benchmark
\`\`\`

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
EOF

    echo "README.md generated"
  '';

  enterShell = ''
    echo "Snix benchmark environment loaded"
    echo ""
    echo "Run 'benchmark' to start the benchmark"
  '';
}
