FROM rust:latest

WORKDIR /home/cc/EnvGym

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    clang \
    lld \
    libssl-dev \
    pkg-config \
    libudev-dev \
    libclang-dev \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN cargo fetch

ENV RUSTFLAGS="-C target-cpu=native"
ENV RUST_BACKTRACE=1
ENV PATH="/home/cc/EnvGym/target/debug:${PATH}"

RUN cargo build --release

CMD ["/bin/bash"]