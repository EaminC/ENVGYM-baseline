FROM ubuntu:20.04

# Avoids interaction during tzdata install
ENV DEBIAN_FRONTEND=noninteractive

# Install curl and nodejs 18 and npm
RUN apt-get update \
    && apt-get install -y curl ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean

# Set up working directory
WORKDIR /repo

# Copy all repo content into the container
COPY . /repo

# Install dependencies from package.json if present
RUN if [ -f package.json ]; then npm install; fi

# Default to bash shell
CMD ["/bin/bash"]
