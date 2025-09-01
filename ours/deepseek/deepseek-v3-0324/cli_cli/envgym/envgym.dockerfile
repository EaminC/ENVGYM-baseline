FROM golang:1.24.6-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    protobuf-compiler \
    unzip \
    wget \
    openssl \
    bash-completion \
    fish \
    zsh \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install goversioninfo
RUN go install github.com/josephspurrier/goversioninfo/cmd/goversioninfo@latest

# Install cloud CLIs
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Docker CLI
RUN curl -fsSL https://get.docker.com | sh

# Install protobuf and gRPC tools
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest \
    && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Set up environment
ENV PATH="/root/go/bin:$PATH"
WORKDIR /app

# Copy repository files
COPY . .

# Initialize Go modules and build
RUN go mod tidy && \
    go mod download && \
    go generate ./internal/codespaces/rpc/codespace && \
    go generate ./internal/codespaces/rpc/jupyter && \
    go generate ./internal/codespaces/rpc/ssh && \
    go build -o bin/gh ./cmd/gh

# Set up shell completions
RUN mkdir -p /usr/share/bash-completion/completions \
    && ./bin/gh completion bash > /usr/share/bash-completion/completions/gh \
    && mkdir -p /root/.config/fish/completions \
    && ./bin/gh completion fish > /root/.config/fish/completions/gh.fish \
    && mkdir -p /root/.zsh/completions \
    && ./bin/gh completion zsh > /root/.zsh/completions/_gh

# Generate documentation (skip if fails)
RUN ./bin/gh generate-docs || true

CMD ["/bin/bash"]