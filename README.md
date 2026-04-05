# ccwc

A Rust implementation of the Unix `wc` (word count) command.

## Usage

```
ccwc [OPTIONS] [FILE...]
```

If no file is provided, reads from stdin.

### Options

| Flag | Description |
|------|-------------|
| `-c` | Print byte count |
| `-l` | Print line count |
| `-w` | Print word count |
| `-m` | Print character count |

With no flags, behaves like `wc`: prints line, word, and byte counts.

## Installation

```sh
cargo install --path .
```

## Nix

The project includes a [Nix flake](https://wiki.nixos.org/wiki/Flakes) for reproducible builds and development environments. It uses [flake-parts](https://flake.parts) for module organisation, [fenix](https://github.com/nix-community/fenix) for the Rust toolchain, and [crane](https://crane.dev) for building.

### Dev shell

Enter the development shell with all tools available:

```sh
nix develop
```

This provides the stable Rust toolchain plus `rust-analyzer`, `cargo-audit`, `cargo-deny`, `cargo-flamegraph`, `cargo-nextest`, `cargo-tarpaulin`, and more.

### Build

```sh
nix build
```

### Checks

Run all checks (clippy, tests via nextest, cargo-machete, cargo-audit, cargo-deny):

```sh
nix flake check
```

## Benchmarking

Build in release mode first, then use [hyperfine](https://github.com/sharkdp/hyperfine) to compare against system `wc`:

```sh
cargo build --release
hyperfine 'wc somefile.txt' './target/release/ccwc somefile.txt'
```
