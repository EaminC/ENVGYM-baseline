# Dockerfile for fastjson2 environment
# Multi-stage build optimized for CPU-only x86_64 environment
FROM maven:3.8.6-openjdk-18 AS builder

# Set context to project root
WORKDIR /project

# Copy necessary build files
COPY pom.xml .
COPY src ./src

# Build without tests
RUN mvn clean package -DskipTests

# Slim runtime image
FROM openjdk:18-jdk-slim

# Set working directory to project root
WORKDIR /project

# Copy built artifact
COPY --from=builder /project/target/fastjson2-*.jar .

# Default to bash shell at project root
CMD ["/bin/bash"]