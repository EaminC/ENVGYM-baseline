FROM rust:latest

# Create and set workdir
WORKDIR /app

# Copy the whole repo to /app
COPY . /app

# Build all workspace members
RUN cargo build --workspace --release

# Default cmd: interactive bash shell in /app
CMD ["/bin/bash"]
