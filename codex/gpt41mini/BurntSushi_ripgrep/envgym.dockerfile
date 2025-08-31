FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl build-essential git \
    && curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && ~/.cargo/bin/rustc --version \
    && ~/.cargo/bin/cargo --version
ENV PATH="$PATH:/root/.cargo/bin"
WORKDIR /app
COPY . /app
RUN cargo install --path .
CMD ["/bin/bash"]

