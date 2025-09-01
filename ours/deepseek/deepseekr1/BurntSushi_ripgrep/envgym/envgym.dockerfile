# Stage 1: Builder
FROM rust:latest AS builder

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential pkg-config libpcre2-dev musl-tools \
    poppler-utils zsh xz-utils lz4 brotli zstd

# Rust toolchain setup
RUN rustup default stable && \
    rustup component add rustfmt && \
    rustup target add \
    i686-unknown-linux-gnu \
    aarch64-unknown-linux-gnu \
    armv7-unknown-linux-gnueabihf \
    armv7-unknown-linux-musleabihf \
    armv7-unknown-linux-musleabi \
    powerpc64-unknown-linux-gnu \
    s390x-unknown-linux-gnu \
    wasm32-wasip1

# Environment configuration
ENV PCRE2_SYS_STATIC=1
RUN mkdir -p /root/.cargo && \
    echo '[target.x86_64-unknown-linux-musl]' >> /root/.cargo/config.toml && \
    echo 'linker = "musl-gcc"' >> /root/.cargo/config.toml
RUN echo "--smart-case\n--max-columns=150" > /root/.ripgreprc

# Project setup
WORKDIR /app
COPY . .

# Preprocessor setup
RUN echo -e '#!/bin/sh\ncase "$1" in *.pdf) pdftotext - - ;; *) cat ;; esac' > preprocessor && \
    chmod +x preprocessor

# Build and test
RUN cargo fmt --all --check
RUN cargo build --release
RUN ./target/release/rg --version
RUN cargo test --all --workspace

# Documentation
RUN ./target/release/rg --generate man > rg.1
RUN ./target/release/rg --generate complete-zsh > _rg

# Final stage
FROM debian:stable-slim
WORKDIR /app

# Copy built artifacts and source
COPY --from=builder /app /app
COPY --from=builder /app/target/release/rg /usr/bin/rg

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    poppler-utils zsh xz-utils lz4 brotli zstd && \
    rm -rf /var/lib/apt/lists/*

# Set entrypoint
ENTRYPOINT ["/bin/bash"]