{
  runCommand,
  runtimeShell,
  succinct-rust,
  rustToolchain,
}:
runCommand "sp1-rust-toolchain" {} ''
  mkdir -p "$out/bin"
  ln -s ${succinct-rust}/lib "$out/lib"
  cat > "$out/bin/rustc" <<EOF
  #!${runtimeShell}
  set -eu

  target=""
  print_value=""
  expect_target=0
  expect_print=0

  for arg in "\$@"; do
    if [ "\$expect_target" -eq 1 ]; then
      target="\$arg"
      expect_target=0
      continue
    fi
    if [ "\$expect_print" -eq 1 ]; then
      print_value="\$arg"
      expect_print=0
      continue
    fi

    case "\$arg" in
      --target)
        expect_target=1
        ;;
      --target=*)
        target="''${arg#--target=}"
        ;;
      --print)
        expect_print=1
        ;;
      --print=*)
        print_value="''${arg#--print=}"
        ;;
    esac
  done

  if [ "''${RUSTUP_TOOLCHAIN:-}" = "succinct" ]; then
    case "''${1:-}" in
      --version|-V|-vV)
        exec ${succinct-rust}/bin/rustc "\$@"
        ;;
    esac

    if [ "\$print_value" = "sysroot" ]; then
      printf '%s\n' "$out"
      exit 0
    fi
  fi

  case "\$target" in
    riscv64im-succinct-zkvm-elf|riscv32im-succinct-zkvm-elf)
      exec ${succinct-rust}/bin/rustc "\$@"
      ;;
  esac

  exec ${rustToolchain}/bin/rustc "\$@"
  EOF
  chmod +x "$out/bin/rustc"
''
