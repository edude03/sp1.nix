{
  description = "SP1 Nix Flake";

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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Helper: flake-parts for easier outputs
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # Systems we want to build for
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      flake = {
        templates = import ./templates;
      };

      perSystem = {
        system,
        pkgs,
        ...
      }: let
        cargo-prove = pkgs.callPackage ./pkgs/cargo-prove.nix {};
        succinct-rust = pkgs.callPackage ./pkgs/succinct-rust.nix {};
        sp1-home = pkgs.callPackage ./pkgs/sp1-home.nix {inherit cargo-prove succinct-rust;};
        rustup-shim = pkgs.callPackage ./pkgs/rustup-shim.nix {
          inherit succinct-rust;
          rustToolchain = pkgs.rustc;
        };
      in {
        packages = {
          inherit cargo-prove succinct-rust sp1-home rustup-shim;
          build-image = pkgs.callPackage ./docker/build-image.nix {};
          run-sp1 = pkgs.callPackage ./docker/run-sp1.nix {};
          sp1-shell = pkgs.callPackage ./docker/sp1-shell.nix {};
        };
        devShells.default = pkgs.mkShell {
          packages = [
            cargo-prove
          ];
          shellHook = ''
            if [ ! -e "$HOME/.sp1" ]; then
              ln -s ${sp1-home} "$HOME/.sp1"
            elif [ ! -L "$HOME/.sp1" ]; then
              echo "Warning: $HOME/.sp1 exists and is not a symlink. SP1 toolchain may not work correctly."
            fi
          '';
        };
      };
    };
}
