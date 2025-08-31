FROM rust:latest
WORKDIR /app
COPY . /app
RUN cargo build --release
CMD ["/bin/bash"]
