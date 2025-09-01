FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y curl git build-essential pkg-config jq p7zip-full \
    gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf unzip clang-format docker.io
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    export PATH="/root/.cargo/bin:$PATH" && \
    rustup component add rustfmt clippy
ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo install cross hyperfine
WORKDIR /fd
RUN git clone https://github.com/sharkdp/fd .
RUN make && make install
RUN mkdir -p /root/.config/fd && echo "*.log" > /root/.config/fd/ignore
RUN mkdir -p test_env/hidden test_env/ignored && \
    touch test_env/file1.txt test_env/hidden/.file2 test_env/ignored/file3.log && \
    echo "ignored/" > test_env/.gitignore
RUN echo '[target.aarch64-unknown-linux-gnu]' > Cross.toml && \
    echo 'env = { JEMALLOC_SYS_WITH_LG_PAGE = "16" }' >> Cross.toml
RUN mkdir -p autocomplete && \
    cp contrib/completion/_fd autocomplete/_fd
CMD ["/bin/bash"]