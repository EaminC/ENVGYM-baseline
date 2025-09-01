FROM rust:1.73.0 AS builder
WORKDIR /usr/src/tokio
RUN git clone --depth 1 https://github.com/tokio-rs/tokio.git .
RUN cargo build --release --example hello_world

FROM debian:bullseye-slim
WORKDIR /usr/src/tokio
COPY --from=builder /usr/src/tokio .
CMD ["/bin/bash"]