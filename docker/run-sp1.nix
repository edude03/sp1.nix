{pkgs, ...}:
pkgs.writeShellScriptBin "sp1-run" ''
  ${pkgs.podman}/bin/podman run -it \
    localhost/cargo-prove:latest
''
