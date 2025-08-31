# syntax=docker/dockerfile:1
FROM rust:1.64-bullseye AS builder
WORKDIR /repo
COPY . .
# Install build dependencies for Ubuntu 20.04 (and for testing/CI if needed):
RUN apt-get update \
    && apt-get install -y make pkg-config libssl-dev \
    && cargo build --release --locked

FROM debian:bullseye-slim
WORKDIR /repo
# Copy built binary and all repo (for interaction, tests and docs)
COPY --from=builder /repo .
COPY --from=builder /repo/target/release/fd /usr/local/bin/fd
# Optionally add bash-completion for fd
#COPY --from=builder /repo/contrib/completion/_fd /etc/bash_completion.d/fd
# Install runtime dependencies and bash
RUN apt-get update && apt-get install -y bash ca-certificates && rm -rf /var/lib/apt/lists/*
# Default command
CMD ["/bin/bash"]
