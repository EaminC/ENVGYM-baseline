FROM openjdk:11-jdk

# Set the working directory inside the container
WORKDIR /app

# Copy entire repository contents to /app
COPY . /app

# Make gradlew executable
RUN chmod +x ./gradlew

# Build the project to install
RUN ./gradlew build --no-daemon

# Default command to open an interactive bash shell
CMD ["/bin/bash"]
