# Use official Rust base image
FROM rust:1.70 as builder

# Create workspace directory
WORKDIR /workspace

# Copy all repo files
COPY . .

# Build all workspace members
RUN cargo build --workspace --release

# Final image: lightweight dev environment
FROM rust:1.70
WORKDIR /workspace
COPY --from=builder /workspace /workspace

# Optional: Provide cargo binaries in PATH (handy for binary crates)
ENV PATH="/workspace/target/release:$PATH"

# Set entrypoint to bash at root
ENTRYPOINT ["/bin/bash"]
