FROM rust:1.57

# Create working directory
WORKDIR /bytes

# Copy repo files to container
COPY . /bytes

# Build the Rust project (using dev build by default)
RUN cargo build

# Start a bash shell at the repo root directory
ENTRYPOINT ["/bin/bash"]
