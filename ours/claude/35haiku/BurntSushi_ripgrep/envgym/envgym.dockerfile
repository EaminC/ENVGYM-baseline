FROM ubuntu:22.04

WORKDIR /ripgrep

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

COPY . .

RUN cargo build --release

RUN ln -s /ripgrep/target/release/rg /usr/local/bin/rg

CMD ["/bin/bash"]