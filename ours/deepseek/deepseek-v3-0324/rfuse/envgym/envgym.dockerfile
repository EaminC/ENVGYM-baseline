# Multi-stage build for optimized size and security
FROM ubuntu:22.04 as builder

# Set working directory matching host system
WORKDIR /home/cc/EnvGym/data/rfuse

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Clone repository
RUN git clone https://github.com/your-repository-url.git .

# Build and install
RUN mkdir build && cd build && \
    cmake .. && \
    make && \
    make install

# Final lightweight image
FROM ubuntu:22.04

# Maintain compatibility with host architecture
ARG TARGETARCH=amd64

# Copy built artifacts from builder
COPY --from=builder /home/cc/EnvGym/data/rfuse /home/cc/EnvGym/data/rfuse

# Set working directory to match host
WORKDIR /home/cc/EnvGym/data/rfuse

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies if needed
COPY requirements.txt .
RUN pip install -r requirements.txt

# Configure environment
ENV PATH="/home/cc/EnvGym/data/rfuse/bin:${PATH}"

# Ensure proper permissions
RUN chmod -R a+rwx /home/cc/EnvGym/data/rfuse

# Entry point
CMD ["/bin/bash"]