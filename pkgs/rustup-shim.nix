{
  symlinkJoin,
  writeShellApplication,
  succinct-rust,
  rustToolchain,
}: let
  # A rustc wrapper that dispatches to the succinct rustc only when
  # compiling for an SP1 riscv target. Build scripts and proc-macros
  # (which compile for the host) use the standard rustc.
  rustc-shim = writeShellApplication {
    name = "rustc";
    runtimeInputs = [];
    text = ''
      # Dispatch to the succinct rustc for SP1 riscv targets, standard
      # rustc for everything else (including build scripts / proc-macros).
      # We check args regardless of RUSTUP_TOOLCHAIN because RUSTC env
      # may be set globally (not just inside the cargo-shim).
      for arg in "$@"; do
        case "$arg" in
          riscv32im-succinct-zkvm-elf|riscv64im-succinct-zkvm-elf|\
          *riscv32im-succinct*|*riscv64im-succinct*)
            exec ${succinct-rust}/bin/rustc "$@"
            ;;
        esac
      done
      exec ${rustToolchain}/bin/rustc "$@"
    '';
  };

  cargo-shim = writeShellApplication {
    name = "cargo";
    runtimeInputs = [];
    text = ''
      if [ "''${RUSTUP_TOOLCHAIN:-}" = "succinct" ]; then
        # Set RUSTC to our rustc-shim which dispatches based on --target.
        # This ensures build scripts use the standard rustc while SP1
        # riscv targets use the succinct rustc.
        export RUSTC="${rustc-shim}/bin/rustc"
      fi
      exec ${rustToolchain}/bin/cargo "$@"
    '';
  };

  # Handles the +succinct parameter the succinct compiler
  # uses (it assumes you have rustup). While it's possible
  # to have rustup in a nix derivation its pretty complicated
  # so this is a minimal wrapper that dispatches to the correct
  # rust toolchain instead.
  rustup-shim = writeShellApplication {
    name = "rustup";
    runtimeInputs = [];
    text = ''
      # Minimal rustup shim for SP1 build compatibility.
      # Handles the subset of rustup commands that sp1-build uses.
      case "''${1:-}" in
        "which")
          shift
          case "''${1:-}" in
            "rustc")
              # Always return the rustc-shim so that cargo-prove (which
              # sets RUSTC from `rustup which rustc`) uses our target-aware
              # dispatcher instead of the raw succinct binary.
              echo "${rustc-shim}/bin/rustc"
              ;;
            "cargo")
              echo "${rustToolchain}/bin/cargo"
              ;;
            *)
              echo "${rustToolchain}/bin/''${1:-}" ;;
          esac
          ;;
        "run")
          shift
          toolchain="''${1:-}"
          shift
          if [ "$toolchain" = "succinct" ]; then
            export RUSTUP_TOOLCHAIN=succinct
            exec "$@"
          else
            exec "$@"
          fi
          ;;
        "toolchain")
          case "''${2:-}" in
            "list")
              echo "succinct"
              echo "default"
              ;;
            *)
              echo "rustup-shim: unsupported command: toolchain ''${2:-}" >&2
              exit 1
              ;;
          esac
          ;;
        "show")
          echo "rustup home: ''${RUSTUP_HOME:-unknown}"
          echo ""
          echo "installed toolchains"
          echo "--------------------"
          echo "succinct"
          echo ""
          echo "active toolchain"
          echo "----------------"
          echo "''${RUSTUP_TOOLCHAIN:-default}"
          ;;
        "--version"|"-V")
          echo "rustup-shim (sp1.nix)"
          ;;
        *)
          echo "rustup-shim: unsupported command: ''${1:-}" >&2
          echo "This is a minimal rustup shim for SP1/Nix builds." >&2
          exit 1
          ;;
      esac
    '';
  };
in
  symlinkJoin {
    name = "rust-toolchain-with-succinct";
    paths = [rustc-shim cargo-shim rustup-shim rustToolchain];
  }
