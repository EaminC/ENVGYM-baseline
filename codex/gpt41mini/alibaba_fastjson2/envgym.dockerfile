FROM maven:3.9.3-eclipse-temurin-17

# Set working directory
WORKDIR /usr/src/app

# Copy all files including hidden ones
COPY . /usr/src/app

# Ensure mvnw has execution permissions
RUN chmod +x mvnw

# Build the project using Maven wrapper
RUN ./mvnw clean install -DskipTests

# Default command: start bash shell at root of repo
CMD ["/bin/bash"]
