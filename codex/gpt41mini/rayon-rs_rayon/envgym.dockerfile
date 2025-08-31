FROM rust:latest

# Set working directory inside the container
WORKDIR /rayon-rs_rayon

# Copy the entire project into the container
COPY . .

# Build the project to install dependencies and produce compiled artifacts
RUN cargo build --release

# Default command to keep container running with bash shell
CMD ["/bin/bash"]
