{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  protobuf,
  openssl,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "cargo-prove";
  version = "6.0.2";

  src = fetchFromGitHub {
    owner = "succinctlabs";
    repo = "sp1";
    rev = "v${version}";
    hash = "sha256-DJ3/BlGJX9eLsBPMsmKtnoJYF9vgkxKn32dybQVggxA=";
  };

  cargoHash = "sha256-6MCx5a6vydi34YvWgN+8Sj69FCZugHabQGXowv+550g=";

  buildAndTestSubdir = "crates/cli";

  # Tests require network access which is not available in sandboxed Nix builds.
  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    protobuf
  ];

  buildInputs = [
    openssl
  ];

  meta = with lib; {
    description = "CLI for SP1, a performant zkVM";
    homepage = "https://github.com/succinctlabs/sp1";
    license = with licenses; [mit asl20];
    maintainers = [];
    mainProgram = "cargo-prove";
  };
}
