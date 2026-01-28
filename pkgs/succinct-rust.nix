{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}: let
  version = "succinct-1.92.0-64bit";

  platforms = {
    x86_64-linux = {
      target = "x86_64-unknown-linux-gnu";
      hash = "sha256-PVpVMgojQaOiof3DFLW1A4RBSk1SRYXBdbd/arA74Ng=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-gnu";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    x86_64-darwin = {
      target = "x86_64-apple-darwin";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
  };

  platform = platforms.${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");
in
  stdenv.mkDerivation {
    pname = "succinct-rust";
    inherit version;

    src = fetchurl {
      url = "https://github.com/succinctlabs/rust/releases/download/${version}/rust-toolchain-${platform.target}.tar.gz";
      hash = platform.hash;
    };

    sourceRoot = ".";

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
      autoPatchelfHook
    ];

    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
      stdenv.cc.cc.lib
      zlib
    ];

    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';

    meta = with lib; {
      description = "Succinct's fork of Rust for SP1 zkVM";
      homepage = "https://github.com/succinctlabs/rust";
      license = with licenses; [mit asl20];
      platforms = builtins.attrNames platforms;
      maintainers = [];
    };
  }
