# Stage 1: Build stage
FROM debian:bookworm-slim AS builder

# Set platform and working directory
WORKDIR /home/cc/EnvGym/data/alibaba_fastjson2

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-11-jdk \
    maven \
    git \
    gcc \
    make \
    && rm -rf /var/lib/apt/lists/*

# Clone repository and build
RUN git clone https://github.com/alibaba/fastjson2.git . && \
    mvn clean install -DskipTests

# Stage 2: Runtime stage
FROM debian:bookworm-slim

# Set working directory
WORKDIR /home/cc/EnvGym/data/alibaba_fastjson2

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-11-jdk-headless \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy built artifacts from builder
COPY --from=builder /home/cc/EnvGym/data/alibaba_fastjson2 .

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | awk '$1 > 80 {exit 1}'

# Set entrypoint
ENTRYPOINT ["/bin/bash"]