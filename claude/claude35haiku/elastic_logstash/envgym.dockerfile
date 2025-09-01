FROM eclipse-temurin:17-jdk-jammy as builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ruby-full \
    bundler \
    rake \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /logstash

# Copy project files
COPY . .

# Install development dependencies
RUN ./gradlew bootstrap

# Final stage
FROM eclipse-temurin:17-jre-jammy

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ruby-full \
    bundler \
    && rm -rf /var/lib/apt/lists/*

# Copy built artifacts from builder stage
COPY --from=builder /logstash /logstash

WORKDIR /logstash

# Set up entrypoint to start bash
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]