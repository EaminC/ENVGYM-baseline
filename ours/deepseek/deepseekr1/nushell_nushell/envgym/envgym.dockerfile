FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    python3 \
    python3-pip \
    docker.io \
    git \
    curl

RUN pip3 install virtualenv

RUN groupadd -g 1000 devuser && \
    useradd -u 1000 -g devuser -m devuser && \
    usermod -aG docker devuser

USER devuser
WORKDIR /home/devuser
ENV PATH="/home/devuser/.cargo/bin:${PATH}"

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    rustup toolchain install 1.87.0 beta && \
    rustup default 1.87.0 && \
    rustup target add wasm32-unknown-unknown

RUN git clone https://github.com/nushell/nushell && \
    git clone https://github.com/nushell/nu_scripts

WORKDIR /home/devuser/nushell
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
RUN cargo build --release --features=full

RUN mkdir -p /home/devuser/.config/nushell
RUN chmod 755 /home/devuser/.config/nushell
RUN ./target/release/nu --version
RUN ./target/release/nu -c "config reset" || true

WORKDIR /home/devuser/nushell
CMD ["/bin/bash"]