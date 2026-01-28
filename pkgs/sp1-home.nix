{
  stdenv,
  cargo-prove,
  succinct-rust,
}: let
  rustTarget = stdenv.hostPlatform.rust.rustcTarget;
in
  stdenv.mkDerivation {
    name = "sp1-home";

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      toolchain="$out/toolchains/${succinct-rust.version}-rust-${rustTarget}"
      mkdir -p "$toolchain"
      for d in bin lib; do
        ln -s ${succinct-rust}/$d "$toolchain/$d"
      done
      ln -s ${cargo-prove}/bin/cargo-prove "$out/bin/cargo-prove"
    '';
  }
