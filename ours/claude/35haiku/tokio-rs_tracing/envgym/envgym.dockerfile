FROM rust:1.74-slim-bullseye

ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH
ENV CARGO_BUILD_JOBS=96
ENV RUST_BACKTRACE=1

RUN apt-get update && apt-get install -y \
    git \
    npm \
    nodejs \
    build-essential \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get install -y nodejs

RUN rustup install stable-x86_64-unknown-linux-gnu
RUN rustup install nightly-x86_64-unknown-linux-gnu
RUN rustup default stable-x86_64-unknown-linux-gnu

RUN cargo install cargo-audit
RUN cargo install cargo-nextest
RUN rustup component add clippy
RUN npm install -g netlify-cli --unsafe-perm

WORKDIR /app

COPY . .

RUN cargo build --release

CMD ["/bin/bash"]