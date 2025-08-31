FROM rust:1.74-bullseye

# Install general dependencies if needed (you can add more as per needs):
RUN apt-get update && apt-get install -y \
    git \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create workspace and set as working directory
WORKDIR /workspace

# Copy repo contents into the image
COPY . /workspace

# Build & install bat from the repo
RUN cargo install --path . --locked

# Set the default shell
CMD ["/bin/bash"]
