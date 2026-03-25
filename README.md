# sp1.nix

Nix packages for [SP1](https://github.com/succinctlabs/sp1), a performant zkVM.

## Quick Start

Create a new SP1 project from the template:

```
nix flake new --template github:argumentcomputer/sp1.nix ./my-project
```

Then enter a dev shell and run the proof:

```
cd my-project
nix develop
cd script && cargo run --release -- --prove
```

See the [template README](templates/hello-world/README.md) for more details on running proofs.

## Packages

Build individual packages with `nix build`:

```
nix build .#cargo-prove
nix build .#succinct-rust
nix build .#sp1-home
nix build .#rustup-shim
```

| Package | Description |
|---------|-------------|
| `cargo-prove` | SP1 CLI (`cargo prove`) |
| `succinct-rust` | Succinct's patched Rust toolchain |
| `sp1-home` | Composed `~/.sp1` home directory |
| `rustup-shim` | Shim that routes `rustc` to `succinct-rust` when `RUSTUP_TOOLCHAIN=succinct` |

## Dev Shell

```
nix develop
```

Provides `cargo-prove` and sets up `~/.sp1` pointing to the Nix-built toolchain.

## Docker

Three helper scripts are available for building and running SP1 in a container:

```
nix build .#build-image   # Build the SP1 Docker image with podman
nix build .#run-sp1       # Run an interactive SP1 container
nix build .#sp1-shell     # Manage a persistent SP1 container shell
```

See the [docker directory](docker/) for the Dockerfile and package definitions.
