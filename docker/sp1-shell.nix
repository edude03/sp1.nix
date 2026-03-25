# Container will continue running on exit, re-running will attach previous shell
# Remove with `podman kill sp1-dev && podman rm sp1-dev`
{pkgs, ...}:
pkgs.writeShellScriptBin "sp1-shell" ''
  set -e

  CONTAINER_NAME="''${SP1_CONTAINER_NAME:-sp1-dev}"
  IMAGE_NAME="''${SP1_IMAGE:-localhost/cargo-prove:latest}"
  SHELL="''${SP1_SHELL:-/bin/bash}"

  # Check if container exists
  if ${pkgs.podman}/bin/podman container exists "$CONTAINER_NAME"; then
    # Container exists, check if it's running
    STATUS=$(${pkgs.podman}/bin/podman inspect -f '{{.State.Status}}' "$CONTAINER_NAME")

    if [ "$STATUS" != "running" ]; then
      echo "Starting stopped container: $CONTAINER_NAME"
      ${pkgs.podman}/bin/podman start "$CONTAINER_NAME"
    else
      echo "Container $CONTAINER_NAME is already running"
    fi
  else
    # Container doesn't exist, create it in detached mode
    echo "Creating new container: $CONTAINER_NAME"
    ${pkgs.podman}/bin/podman run -dit \
      --name "$CONTAINER_NAME" \
      "$IMAGE_NAME" \
      "$SHELL"
  fi

  # Enter the container using exec
  echo "Entering container... (container will persist after exit)"
  ${pkgs.podman}/bin/podman exec -it "$CONTAINER_NAME" "$SHELL"
''
# --privileged \
#--ulimit memlock=-1:-1 \
#--ipc=host \

