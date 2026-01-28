{pkgs, ...}: let
  dockerfile = ./Dockerfile;
in
  pkgs.writeShellScriptBin "sp1-build" ''
    echo "Building SP1 image"
    ${pkgs.podman}/bin/podman build \
      -f ${dockerfile} \
      -t localhost/cargo-prove:latest \
      "''${1:-$PWD}"
  ''
