{
  lib,
  writeShellApplication,
  succinct-rust,
  rustc,
}:
writeShellApplication {
  name = "rustc";
  runtimeInputs = [];
  text = ''
    if [ "''${RUSTUP_TOOLCHAIN:-}" = "succinct" ]; then
      exec ${succinct-rust}/bin/rustc "$@"
    else
      exec ${rustc}/bin/rustc "$@"
    fi
  '';
}
