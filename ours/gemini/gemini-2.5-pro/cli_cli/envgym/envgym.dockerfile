# Use the official Go image matching the required version from the plan
FROM golang:1.24.6-bookworm

# Set environment variables for tool versions, paths, and user configuration
ENV GOLANGCI_LINT_VERSION=1.59.1
ENV GORELEASER_VERSION=1.17.1
# A recent stable version for CodeQL CLI, as none was specified in the plan
ENV CODEQL_CLI_VERSION=v2.18.3
ENV NODE_VERSION=20
ENV REPO_PATH=/home/cc/EnvGym/data/cli_cli
# Set GOPATH outside the user's home to avoid potential conflicts with cloned repos
ENV GOPATH=/go
# Add Go bin, local bin, and CodeQL to the PATH
ENV PATH=${GOPATH}/bin:/usr/local/go/bin:/usr/local/bin:${REPO_PATH}/codeql:${PATH}

# Install system-level dependencies, developer tools, and create the user/directory structure
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    curl \
    git \
    gnupg \
    make \
    reprepro \
    unzip \
    wget && \
    # Install Node.js and npm (for GitHub Actions development)
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs && \
    # Clean up apt caches to reduce image size
    rm -rf /var/lib/apt/lists/* && \
    # Create the user and directory structure as specified in the plan
    # Use GID 100 (users) which is common, and UID 1000
    useradd --uid 1000 --gid 100 --shell /bin/bash --create-home cc && \
    mkdir -p ${REPO_PATH} ${GOPATH}/src ${GOPATH}/bin && \
    chown -R cc:100 /home/cc ${GOPATH}

# Install Go-based and other command-line tools system-wide
# golangci-lint
RUN wget -O- -q https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64.tar.gz | tar -xzf - -C /usr/local/bin --strip-components=1 golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64/golangci-lint

# GoReleaser
RUN wget https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser_Linux_x86_64.tar.gz -O goreleaser.tar.gz && \
    tar -zxvf goreleaser.tar.gz goreleaser && \
    mv goreleaser /usr/local/bin/goreleaser && \
    rm goreleaser.tar.gz

# direnv
RUN wget https://github.com/direnv/direnv/releases/download/v2.34.0/direnv.linux-amd64 -O /usr/local/bin/direnv && \
    chmod +x /usr/local/bin/direnv

# Switch to the non-root user for subsequent operations
USER cc
WORKDIR /home/cc

# Install user-specific Go tools as per the plan's `go install` commands
RUN go install github.com/google/go-licenses@5348b744d0983d85713295ea08a20cca1654a45e && \
    go install golang.org/x/vuln/cmd/govulncheck@d1f380186385b4f64e00313f31743df8e4b89a77

# Clone the target repository into an empty directory
RUN git clone https://github.com/cli/cli.git ${REPO_PATH}

# Set the final working directory to the repository root
WORKDIR ${REPO_PATH}

# CodeQL CLI (installed into the project directory structure to be on the PATH)
# This must be run AFTER cloning the repo so the target directory exists.
RUN wget https://github.com/github/codeql-cli-binaries/releases/download/${CODEQL_CLI_VERSION}/codeql-linux64.zip -O codeql.zip && \
    unzip codeql.zip && \
    rm codeql.zip

# Download and verify Go module dependencies to pre-warm the cache
RUN go mod download && go mod verify

# Set the default command to a bash shell for an interactive session
CMD ["/bin/bash"]