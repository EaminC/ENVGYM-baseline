FROM debian:stable-slim AS builder

WORKDIR /home/cc/EnvGym/data/sveltejs_svelte

RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY . .

FROM debian:stable-slim

WORKDIR /home/cc/EnvGym/data/sveltejs_svelte

COPY --from=builder /home/cc/EnvGym/data/sveltejs_svelte .

RUN apt-get update && apt-get install -y \
    bash \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]