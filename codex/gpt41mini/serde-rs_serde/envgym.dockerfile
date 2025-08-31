FROM rust:latest

WORKDIR /repo

# Copy the entire repo into the container
COPY . /repo

# Build the repo to install dependencies
RUN cargo build --release

# Default to bash shell
CMD ["/bin/bash"]
