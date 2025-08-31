FROM rust:1.87.0

WORKDIR /usr/src/nu

# Copy all the repo files into the container
COPY . .

# Build the project in release mode
RUN cargo build --release

# Default to bash shell
CMD ["/bin/bash"]
