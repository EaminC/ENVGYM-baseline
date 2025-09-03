FROM rust:slim-bullseye AS builder
WORKDIR /app
COPY . .
RUN apt-get update && \
    apt-get install -y --no-install-recommends git build-essential cmake && \
    rustup component add rustfmt && \
    cargo install cargo-edit && \
    cd rayon-demo && \
    cargo build --release --verbose

FROM debian:bullseye-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates libssl-dev git build-essential cargo rustc && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . .
COPY --from=builder /app/rayon-demo/target/release/rayon-demo /usr/local/bin/rayon-demo
RUN chmod +x /usr/local/bin/rayon-demo
SHELL ["/bin/bash", "-c"]
CMD ["/bin/bash"]