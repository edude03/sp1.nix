{
  description = "SP1 template Nix flake";

  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  inputs = {
    # System packages
    nixpkgs.follows = "sp1/nixpkgs";

    # Helper: flake-parts for easier outputs
    flake-parts.follows = "sp1/flake-parts";

    # Rust toolchain
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sp1 = {
      url = "github:argumentcomputer/sp1.nix";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    fenix,
    sp1,
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # Systems we want to build for
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem = {
        system,
        pkgs,
        ...
      }: let
        # Pins the Rust toolchain with succinct support
        rustToolchain = sp1.packages.${system}.rustup-shim.override {
          rustToolchain = fenix.packages.${system}.fromToolchainFile {
            file = ./rust-toolchain.toml;
            # Update this hash when `rust-toolchain.toml` changes
            # Just copy the expected hash from the `nix build` error message
            sha256 = "sha256-SBKjxhC6zHTu0SyJwxLlQHItzMzYZ71VCWQC2hOzpRY=";
          };
        };
      in {
        packages = {
          default = pkgs.hello;
        };
        devShells.default = pkgs.mkShell {
          inputsFrom = [sp1.devShells.${system}.default];
          packages = [
            rustToolchain
          ];
        };
      };
    };
}
