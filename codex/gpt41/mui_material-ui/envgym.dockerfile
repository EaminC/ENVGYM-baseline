FROM ubuntu:20.04

# Avoid interactive tzdata/etc
ENV DEBIAN_FRONTEND=noninteractive

# Install system deps: curl, git, node, and pnpm
RUN apt-get update && \
    apt-get install -y curl git ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pnpm@latest && \
    apt-get clean

# Add everything and set working directory
WORKDIR /repo
COPY . /repo

# Install dependencies
RUN pnpm install

# Entrypoint: bash shell
CMD ["/bin/bash"]
