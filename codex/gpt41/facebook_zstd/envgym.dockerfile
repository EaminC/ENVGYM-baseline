FROM ubuntu:22.04

# Install build essentials and dependencies
RUN apt-get update && \
    apt-get install -y build-essential gcc make git pkg-config \
    && apt-get clean

# Set up workdir at repo root
WORKDIR /facebook_zstd

# Copy all repo files in
COPY . /facebook_zstd/

# Build and install zstd
RUN make && make install

# Default entry: interactive bash shell
CMD ["/bin/bash"]
