FROM rust:1.77.2-slim
WORKDIR /repo
COPY . /repo
RUN apt-get update && apt-get install -y build-essential &&     cargo build --release --locked &&     apt-get remove -y build-essential && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*
CMD ["/bin/bash"]
