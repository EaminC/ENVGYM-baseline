FROM rust:1.80-bookworm

WORKDIR /home/cc/EnvGym

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    gdb \
    strace \
    xz-utils \
    linux-perf \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/cc/EnvGym/data/rayon-rs_rayon && \
    mkdir -p /home/cc/EnvGym/.cargo

COPY . /home/cc/EnvGym/data/rayon-rs_rayon

RUN echo '[target.x86_64-unknown-linux-gnu]\nrunner = "env LD_LIBRARY_PATH=/usr/local/lib"' > /home/cc/EnvGym/.cargo/config.toml

WORKDIR /home/cc/EnvGym/data/rayon-rs_rayon

RUN cargo build --release

RUN sysctl -w kernel.perf_event_paranoid=1 || true

WORKDIR /home/cc/EnvGym/data/rayon-rs_rayon

CMD ["/bin/bash"]