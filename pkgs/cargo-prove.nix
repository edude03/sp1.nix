{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "cargo-prove";
  version = "5.2.4";

  src = fetchFromGitHub {
    owner = "succinctlabs";
    repo = "sp1";
    rev = "v${version}";
    hash = "sha256-sCQOZmhuMETn08eYtIDO2Vckx/oBclmReoVYYNGEb38=";
  };

  cargoHash = "sha256-DAkJwQJXt68/GU04fIulXOB8utqoyNr+1j5VBWRoRXo=";

  buildAndTestSubdir = "crates/cli";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  meta = with lib; {
    description = "CLI for SP1, a performant zkVM";
    homepage = "https://github.com/succinctlabs/sp1";
    license = with licenses; [mit asl20];
    maintainers = [];
    mainProgram = "cargo-prove";
  };
}
