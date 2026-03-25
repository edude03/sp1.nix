FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Base SP1 dependencies
RUN apt-get update && apt-get install -y \
  curl build-essential git \
#     xz-utils jq curl build-essential qemu-system \
#     libomp-dev libgmp-dev nlohmann-json3-dev protobuf-compiler \
#     uuid-dev libgrpc++-dev libsecp256k1-dev libsodium-dev \
#     libpqxx-dev nasm libopenmpi-dev openmpi-bin openmpi-common \
#     libclang-dev clang gcc-riscv64-unknown-elf git \
  && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install SP1 via sp1up
RUN curl -L https://sp1up.succinct.xyz | bash
ENV PATH="/root/.sp1/bin:${PATH}"
RUN sp1up

WORKDIR /workspace

CMD ["/bin/bash"]
