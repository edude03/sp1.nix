{
  symlinkJoin,
  writeShellApplication,
  succinct-rust,
  rustToolchain,
}:
let
  rustc-shim = writeShellApplication {
    name = "rustc";
    runtimeInputs = [];
    text = ''
      if [ "''${RUSTUP_TOOLCHAIN:-}" = "succinct" ]; then
        exec ${succinct-rust}/bin/rustc "$@"
      fi
      exec ${rustToolchain}/bin/rustc "$@"
    '';
  };
in
symlinkJoin {
  name = "rust-toolchain-with-succinct";
  paths = [rustc-shim rustToolchain];
}
