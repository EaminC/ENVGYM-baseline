# Start with Ubuntu 22.04 base image, which is consistent with the CI environment
FROM ubuntu:22.04

# Set non-interactive mode for package installations to prevent prompts
ENV DEBIAN_FRONTEND=noninteractive

# Define an argument for the Verus commit, allowing it to be overridden at build time
ARG VERUS_COMMIT=8bd7c3292aad57d3926ed8024cde13ca53d6e1a7

# Set up environment variables for Go, Rust, and Verus, and add them to the system PATH
ENV GOPATH=/go
ENV CARGO_HOME=/root/.cargo
ENV RUSTUP_HOME=/root/.rustup
ENV PATH=/root/.cargo/bin:/go/bin:/usr/local/go/bin:$PATH
ENV VERUS_DIR=/home/cc/EnvGym/data/anvil/verus

# Set the primary working directory as specified in the plan
WORKDIR /home/cc/EnvGym/data/anvil

# Install all system prerequisites, Python dependencies, and Kubernetes tools in a single layer to optimize image size
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    golang-go \
    docker.io \
    openssl \
    pkg-config \
    libssl-dev \
    python3 \
    python3-pip \
    wget \
    unzip \
    curl \
    ca-certificates \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install tabulate \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl \
    && go install sigs.k8s.io/kind@v0.23.0

# Install the Rust toolchain manager (rustup) without a default toolchain initially
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none -y

# Explicitly set the shell to bash for better script compatibility
SHELL ["/bin/bash", "-c"]

# Clone, configure, and build the specific version of the Verus tool from source
RUN git clone https://github.com/verus-lang/verus.git \
    && cd verus \
    && git checkout ${VERUS_COMMIT} \
    && . "$CARGO_HOME/env" \
    && rustup toolchain install \
    && cd source \
    && ./tools/get-z3.sh \
    && . ../tools/activate \
    && vargo clean \
    && vargo build --release

# Create the complete project directory structure
RUN mkdir -p verifiable-controllers/.github/workflows \
    && mkdir -p verifiable-controllers/src/deps_hack/src \
    && mkdir -p verifiable-controllers/deploy/{vreplicaset,vdeployment,vstatefulset,zookeeper,rabbitmq,fluent} \
    && mkdir -p verifiable-controllers/e2e/src \
    && mkdir -p verifiable-controllers/e2e/manifests \
    && mkdir -p verifiable-controllers/docker/controller \
    && mkdir -p verifiable-controllers/docker/verus \
    && mkdir -p verifiable-controllers/tools

# Create all project files as specified in the plan using heredocs
RUN <<EOF > verifiable-controllers/.gitignore
# Except this file
!.gitignore
.vscode/
src/*_controller
src/*.long-type-*.txt
src/.verus-log/
e2e/target/
/target
/Cargo.lock
src/liblib.rlib
verifiable-controllers.code-workspace
src/.verus-solver-log/
src/*.d
src/*.rlib
tools/*.json
vreplicaset_controller.*.txt
certs
EOF

RUN <<EOF > verifiable-controllers/.github/workflows/ci.yml
name: Continuous integration
run-name: Continuous integration run by \${{ github.actor }}
on:
  # push:
  #   branches:
  #     - main
  #   paths-ignore:
  #     - "README.md"
  #     - ".gitignore"
  #     - "doc/**"
  pull_request:
  merge_group:
  workflow_dispatch:
env:
  verus_commit: 8bd7c3292aad57d3926ed8024cde13ca53d6e1a7
  kind_version: 0.23.0
  go_version: "^1.20"
  home_dir: /home/runner

jobs:
  build-and-cache-verus:
  # keep consistent with dockerfile
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
      - name: Get HOME env variable
        id: get-home
        run: |
          echo "home_dir=\$HOME" >> \$GITHUB_ENV
          echo "home_dir=\$HOME"
      - name: Find Verus build and Rust toolchain from cache
        id: cache-verus
        uses: actions/cache@v4
        with:
          path: |
            \${{ env.home_dir }}/verus/source
            \${{ env.home_dir }}/verus/dependencies
            \${{ env.home_dir }}/.cargo
            \${{ env.home_dir }}/.rustup
          key: verus-\${{ runner.os }}-\${{ env.verus_commit }}-\${{ hashFiles('rust-toolchain.toml') }}
      - name: Download Verus if cache is missing
        if: steps.cache-verus.outputs.cache-hit != 'true'
        uses: actions/checkout@v4
        with:
          repository: verus-lang/verus
          path: verus
          ref: \${{ env.verus_commit }}
      - name: Download Rust toolchain and build Verus if cache is missing
        if: steps.cache-verus.outputs.cache-hit != 'true'
        run: |
          mv verus \$HOME/verus
          cd \$HOME/verus
          curl --proto '=https' --tlsv1.2 --retry 10 --retry-connrefused -fsSL "https://sh.rustup.rs" | sh -s -- --default-toolchain none -y
          . "\$HOME/.cargo/env"
          rustup toolchain install
          cd source
          ./tools/get-z3.sh
          . ../tools/activate
          vargo clean
          vargo build --release
  anvil-verification:
    needs: build-and-cache-verus
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
      - name: Restore Verus cache
        uses: actions/cache@v4
        with:
          path: |
            \${{ env.home_dir }}/verus/source
            \${{ env.home_dir }}/verus/dependencies
            \${{ env.home_dir }}/.cargo
            \${{ env.home_dir }}/.rustup
          key: verus-\${{ runner.os }}-\${{ env.verus_commit }}-\${{ hashFiles('rust-toolchain.toml') }}
      - name: Verify Anvil framework
        run: |
          . "\$HOME/.cargo/env"
          VERUS_DIR="\${HOME}/verus" ./build.sh anvil.rs --crate-type=lib --rlimit 50 --time
  vreplicaset-verification:
    needs: build-and-cache-verus
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
      - name: Restore Verus cache
        uses: actions/cache@v4
        with:
          path: |
            \${{ env.home_dir }}/verus/source
            \${{ env.home_dir }}/verus/dependencies
            \${{ env.home_dir }}/.cargo
            \${{ env.home_dir }}/.rustup
          key: verus-\${{ runner.os }}-\${{ env.verus_commit }}-\${{ hashFiles('rust-toolchain.toml') }}
      - name: Verify vreplicaset controller
        run: |
          . "\$HOME/.cargo/env"
          VERUS_DIR="\${HOME}/verus" ./build.sh vreplicaset_controller.rs --rlimit 50 --time --verify-module vreplicaset_controller
  vdeployment-verification:
    needs: build-and-cache-verus
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
      - name: Restore Verus cache
        uses: actions/cache@v4
        with:
          path: |
            \${{ env.home_dir }}/verus/source
            \${{ env.home_dir }}/verus/dependencies
            \${{ env.home_dir }}/.cargo
            \${{ env.home_dir }}/.rustup
          key: verus-\${{ runner.os }}-\${{ env.verus_commit }}-\${{ hashFiles('rust-toolchain.toml') }}
      - name: Verify vdeployment controller
        run: |
          . "\$HOME/.cargo/env"
          VERUS_DIR="\${HOME}/verus" ./build.sh vdeployment_controller.rs --rlimit 50 --time --verify-module vdeployment_controller
  zookeeper-verification:
    needs: build-and-cache-verus
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
      - name: Restore Verus cache
        uses: actions/cache@v4
        with:
          path: |
            \${{ env.home_dir }}/verus/source
            \${{ env.home_dir }}/verus/dependencies
            \${{ env.home_dir }}/.cargo
            \${{ env.home_dir }}/.rustup
          key: verus-\${{ runner.os }}-\${{ env.verus_commit }}-\${{ hashFiles('rust-toolchain.toml') }}
      - name: Verify Zookeeper controller
        run: |
          . "\$HOME/.cargo/env"
          VERUS_DIR="\${HOME}/verus" ./build.sh zookeeper_controller.rs --rlimit 50 --time --verify-module zookeeper_controller
  vreplicaset-e2e-test:
    needs:
      - build-and-cache-verus
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
      - name: Restore Verus cache
        uses: actions/cache@v4
        with:
          path: |
            \${{ env.home_dir }}/verus/source
            \${{ env.home_dir }}/verus/dependencies
            \${{ env.home_dir }}/.cargo
            \${{ env.home_dir }}/.rustup
          key: verus-\${{ runner.os }}-\${{ env.verus_commit }}-\${{ hashFiles('rust-toolchain.toml') }}
      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: \${{ env.go_version }}
      - name: Install kind
        run: go install sigs.k8s.io/kind@v\$kind_version
      - name: Build Verus toolchain image
        run: docker build --build-arg VERUS_VER="\${{ env.verus_commit }}" -t verus-toolchain:local docker/verus
      - name: Deploy vreplicaset controller
        run: ./local-test.sh vreplicaset --build-remote
      - name: Run vreplicaset e2e tests
        run: . "\$HOME/.cargo/env" && cd e2e && cargo run -- vreplicaset
EOF

RUN <<EOF > verifiable-controllers/.github/workflows/controller-build.yml
name: Controller build
on:
  workflow_dispatch:
env:
  IMAGE_NAME: \${{ github.repository }}
jobs:
  build-zookeeper-controller:
    runs-on: ubuntu-22.04
    permissions:
      contents: read
      packages: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Log into registry ghcr.io
        run: echo "\${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u "\${{ github.actor }}" --password-stdin
      - name: Build zookeeper controller image
        run: |
          docker build -t ghcr.io/\${{ env.IMAGE_NAME }}/zookeeper-controller:latest \\
            --build-arg APP=zookeeper \\
            --build-arg BUILDER_IMAGE=ghcr.io/\${{ env.IMAGE_NAME }}/verus:latest \\
            -f docker/controller/Dockerfile.remote .
          docker tag ghcr.io/\${{ env.IMAGE_NAME }}/zookeeper-controller:latest ghcr.io/\${{ env.IMAGE_NAME }}/zookeeper-controller:\${{ github.sha }}
      - name: Push zookeeper controller image
        run: |
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/zookeeper-controller:latest
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/zookeeper-controller:\${{ github.sha }}
  build-rabbitmq-controller:
    runs-on: ubuntu-22.04
    permissions:
      contents: read
      packages: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Log into registry ghcr.io
        run: echo "\${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u "\${{ github.actor }}" --password-stdin
      - name: Build rabbitmq controller image
        run: |
          docker build -t ghcr.io/\${{ env.IMAGE_NAME }}/rabbitmq-controller:latest \\
            --build-arg APP=rabbitmq \\
            --build-arg BUILDER_IMAGE=ghcr.io/\${{ env.IMAGE_NAME }}/verus:latest \\
            -f docker/controller/Dockerfile.remote .
          docker tag ghcr.io/\${{ env.IMAGE_NAME }}/rabbitmq-controller:latest ghcr.io/\${{ env.IMAGE_NAME }}/rabbitmq-controller:\${{ github.sha }}
      - name: Push rabbitmq controller image
        run: |
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/rabbitmq-controller:latest
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/rabbitmq-controller:\${{ github.sha }}
  build-fluent-controller:
    runs-on: ubuntu-22.04
    permissions:
      contents: read
      packages: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Log into registry ghcr.io
        run: echo "\${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u "\${{ github.actor }}" --password-stdin
      - name: Build fluent controller image
        run: |
          docker build -t ghcr.io/\${{ env.IMAGE_NAME }}/fluent-controller:latest \\
            --build-arg APP=fluent \\
            --build-arg BUILDER_IMAGE=ghcr.io/\${{ env.IMAGE_NAME }}/verus:latest \\
            -f docker/controller/Dockerfile.remote .
          docker tag ghcr.io/\${{ env.IMAGE_NAME }}/fluent-controller:latest ghcr.io/\${{ env.IMAGE_NAME }}/fluent-controller:\${{ github.sha }}
      - name: Push fluent controller image
        run: |
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/fluent-controller:latest
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/fluent-controller:\${{ github.sha }}
  build-vreplicaset-controller:
    runs-on: ubuntu-22.04
    permissions:
      contents: read
      packages: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Log into registry ghcr.io
        run: echo "\${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u "\${{ github.actor }}" --password-stdin
      - name: Build vreplicaset controller image
        run: |
          docker build -t ghcr.io/\${{ env.IMAGE_NAME }}/vreplicaset-controller:latest \\
            --build-arg APP=vreplicaset \\
            --build-arg BUILDER_IMAGE=ghcr.io/\${{ env.IMAGE_NAME }}/verus:latest \\
            -f docker/controller/Dockerfile.remote .
          docker tag ghcr.io/\${{ env.IMAGE_NAME }}/vreplicaset-controller:latest ghcr.io/\${{ env.IMAGE_NAME }}/vreplicaset-controller:\${{ github.sha }}
      - name: Push vreplicaset controller image
        run: |
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/vreplicaset-controller:latest
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/vreplicaset-controller:\${{ github.sha }}
  build-vreplicaset-admission-controller:
    runs-on: ubuntu-22.04
    permissions:
      contents: read
      packages: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Log into registry ghcr.io
        run: echo "\${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u "\${{ github.actor }}" --password-stdin
      - name: Build vreplicaset admission controller image
        run: |
          docker build -t ghcr.io/\${{ env.IMAGE_NAME }}/vreplicaset-admission-controller:latest \\
            --build-arg APP=vreplicaset_admission \\
            --build-arg BUILDER_IMAGE=ghcr.io/\${{ env.IMAGE_NAME }}/verus:latest \\
            -f docker/controller/Dockerfile.remote .
          docker tag ghcr.io/\${{ env.IMAGE_NAME }}/vreplicaset-admission-controller:latest ghcr.io/\${{ env.IMAGE_NAME }}/vreplicaset-admission-controller:\${{ github.sha }}
      - name: Push vreplicaset admission controller image
        run: |
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/vreplicaset-admission-controller:latest
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/vreplicaset-admission-controller:\${{ github.sha }}
  build-vstatefulset-admission-controller:
    runs-on: ubuntu-22.04
    permissions:
      contents: read
      packages: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Log into registry ghcr.io
        run: echo "\${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u "\${{ github.actor }}" --password-stdin
      - name: Build vstatefulset admission controller image
        run: |
          docker build -t ghcr.io/\${{ env.IMAGE_NAME }}/vstatefulset-admission-controller:latest \\
            --build-arg APP=vstatefulset_admission \\
            --build-arg BUILDER_IMAGE=ghcr.io/\${{ env.IMAGE_NAME }}/verus:latest \\
            -f docker/controller/Dockerfile.remote .
          docker tag ghcr.io/\${{ env.IMAGE_NAME }}/vstatefulset-admission-controller:latest ghcr.io/\${{ env.IMAGE_NAME }}/vstatefulset-admission-controller:\${{ github.sha }}
      - name: Push vstatefulset admission controller image
        run: |
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/vstatefulset-admission-controller:latest
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/vstatefulset-admission-controller:\${{ github.sha }}
  build-vdeployment-admission-controller:
    runs-on: ubuntu-22.04
    permissions:
      contents: read
      packages: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Log into registry ghcr.io
        run: echo "\${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u "\${{ github.actor }}" --password-stdin
      - name: Build vdeployment admission controller image
        run: |
          docker build -t ghcr.io/\${{ env.IMAGE_NAME }}/vdeployment-admission-controller:latest \\
            --build-arg APP=vdeployment_admission \\
            --build-arg BUILDER_IMAGE=ghcr.io/\${{ env.IMAGE_NAME }}/verus:latest \\
            -f docker/controller/Dockerfile.remote .
          docker tag ghcr.io/\${{ env.IMAGE_NAME }}/vdeployment-admission-controller:latest ghcr.io/\${{ env.IMAGE_NAME }}/vdeployment-admission-controller:\${{ github.sha }}
      - name: Push vdeployment admission controller image
        run: |
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/vdeployment-admission-controller:latest
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/vdeployment-admission-controller:\${{ github.sha }}
EOF

RUN <<EOF > verifiable-controllers/.github/workflows/verus-build.yml
name: Verus build
on:
  workflow_dispatch:
env:
  IMAGE_NAME: \${{ github.repository }}
jobs:
  build:
    runs-on: ubuntu-22.04
    permissions:
      contents: read
      packages: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      - name: Log into registry ghcr.io
        run: echo "\${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u "\${{ github.actor }}" --password-stdin
      - name: Build Verus image
        run: |
          cd docker/verus
          docker build -t ghcr.io/\${{ env.IMAGE_NAME }}/verus:latest --build-arg VERUS_VER=8bd7c3292aad57d3926ed8024cde13ca53d6e1a7 .
          docker tag ghcr.io/\${{ env.IMAGE_NAME }}/verus:latest ghcr.io/\${{ env.IMAGE_NAME }}/verus:8bd7c3292aad57d3926ed8024cde13ca53d6e1a7
      - name: Push Verus image
        run: |
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/verus:latest
          docker push ghcr.io/\${{ env.IMAGE_NAME }}/verus:8bd7c3292aad57d3926ed8024cde13ca53d6e1a7
EOF

RUN <<EOF > verifiable-controllers/Cargo.toml
[package]
name = "verifiable-controllers"
version = "0.1.0"
edition = "2021"

[dependencies]
# Add project dependencies here

[lib]
name = "anvil"
path = "src/anvil.rs"
crate-type = ["rlib"]

[[bin]]
name = "vreplicaset_controller"
path = "src/vreplicaset_controller.rs"

[[bin]]
name = "vdeployment_controller"
path = "src/vdeployment_controller.rs"

[[bin]]
name = "vstatefulset_controller"
path = "src/vstatefulset_controller.rs"

[[bin]]
name = "vreplicaset_admission_controller"
path = "src/vreplicaset_admission_controller.rs"

[[bin]]
name = "vdeployment_admission_controller"
path = "src/vdeployment_admission_controller.rs"

[[bin]]
name = "vstatefulset_admission_controller"
path = "src/vstatefulset_admission_controller.rs"

[[bin]]
name = "zookeeper_controller"
path = "src/zookeeper_controller.rs"

[[bin]]
name = "rabbitmq_controller"
path = "src/rabbitmq_controller.rs"

[[bin]]
name = "fluent_controller"
path = "src/fluent_controller.rs"
EOF

RUN <<EOF > verifiable-controllers/rust-toolchain.toml
# this should be synchronized with the Verus version, since we need to combine
# k8s compiled with rustc and our own code compiled with rust-verify.sh
[toolchain]
channel = "1.88.0"
EOF

RUN <<EOF > verifiable-controllers/src/deps_hack/Cargo.toml
[package]
name = "deps_hack"
version = "0.1.0"
edition = "2021"
EOF

RUN <<EOF > verifiable-controllers/build.sh
#!/usr/bin/env bash

## Build and verify the controller example.
##
## Requires VERUS_DIR to be set to the path to verus.

set -eu

# script dir is root of repo
DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "\$DIR/src"

rv=\$VERUS_DIR/source/target-verus/release/verus
cd deps_hack
cargo build
cd ..
# TODO: after the lifetime check is fixed in verus, remove the --no-lifetime flag
"\$rv" -L dependency=deps_hack/target/debug/deps \\
  --extern=deps_hack="deps_hack/target/debug/libdeps_hack.rlib" \\
  --compile \\
  "\$@"
EOF

RUN <<EOF > verifiable-controllers/deploy.sh
#!/usr/bin/env bash

## Deploy the example controller to Kubernetes cluster.
##
## Requires a running Kubernetes cluster and kubectl to be installed.

set -xu

YELLOW='\\033[1;33m'
GREEN='\\033[1;32m'
RED='\\033[0;31m'
NC='\\033[0m'

app=\$(echo "\$1" | tr '_' '-') # should be the controller's name (with words separated by dashes)
app_filename=\$(echo "\$app" | tr '-' '_')
cluster_name="\${app}-e2e"
registry=\$2 # should be either remote or local

kind get clusters | grep \$cluster_name > /dev/null 2>&1
if [ \$? -eq 0 ]; then
    echo -e "\${YELLOW}A kind cluster named \\"\$cluster_name\\" already exists. Deleting...\${NC}"
    kind delete cluster --name \$cluster_name
fi

set -xeu
# Set up the kind cluster and load the image into the cluster
kind create cluster --config deploy/kind.yaml --name \$cluster_name
kind load docker-image local/\$app-controller:v0.1.0 --name \$cluster_name

# for VDeployment, need to deploy VReplicaSet as a dependency
if [ "\$app" == "vdeployment" ]; then
    kind load docker-image local/vreplicaset-controller:v0.1.0 --name \$cluster_name
fi

# admission controller has a different deployment process
if [ \$(echo \$app | awk -F'-' '{print \$NF}') == "admission" ]; then
    app=\${app%-admission}
    app_filename=\${app_filename%_admission}
    set -o pipefail
    kubectl create -f deploy/\${app_filename}/crd.yaml
    echo "Creating Webhook Server Certs"
    mkdir -p certs
    openssl genrsa -out certs/tls.key 2048
    openssl req -new -key certs/tls.key -out certs/tls.csr -subj "/CN=admission-server.default.svc"
    openssl x509 -req -extfile <(printf "subjectAltName=DNS:admission-server.default.svc") -in certs/tls.csr -signkey certs/tls.key -out certs/tls.crt

    echo "Creating Webhook Server TLS Secret"
    kubectl create secret tls admission-server-tls \\
        --cert "certs/tls.crt" \\
        --key "certs/tls.key"
    echo "Creating Webhook Server Deployment"
    sed -e 's@\${APP}@'"\${app}-admission-controller"'@g' <"e2e/manifests/admission_server.yaml" | kubectl create -f -
    CA_PEM64="\$(openssl base64 -A < certs/tls.crt)"
    echo "Creating K8s Webhooks"
    sed -e 's@\${CA_PEM_B64}@'"\$CA_PEM64"'@g' -e 's@\${RESOURCE}@'"\${app#}"s'@g' <"e2e/manifests/admission_webhooks.yaml" | kubectl create -f -
    exit 0
fi

if cd deploy/\$app_filename && { for crd in \$(ls crd*.yaml); do kubectl create -f "\$crd"; done } && kubectl apply -f rbac.yaml && kubectl apply -f deploy_\$registry.yaml; then
    echo ""
    echo -e "\${GREEN}The \$app controller is deployed in your Kubernetes cluster in namespace \\"\$app\\".\${NC}"
    echo -e "\${GREEN}Run \\"kubectl get pod -n \$app\\" to check the controller pod.\${NC}"
    echo -e "\${GREEN}Run \\"kubectl apply -f deploy/\$app_filename/\$app_filename.yaml\\" to deploy the cluster custom resource(s).\${NC}"
else
    echo ""
    echo -e "\${RED}Cannot deploy the controller.\${NC}"
    echo -e "\${YELLOW}Please ensure kubectl can connect to a Kubernetes cluster.\${NC}"
    exit 3
fi
EOF

RUN <<EOF > verifiable-controllers/local-test.sh
#!/usr/bin/env bash

## Test the controller locally in a kind cluster.
##
## Requires kind to be installed and the prerequisites of deploy.sh.
## Usage: ./local-test.sh <controller_name> [--no-build]

set -xeu

app=\$(echo "\$1" | tr '_' '-')
app_filename=\$(echo "\$app" | tr '-' '_')
build_controller="no"
dockerfile_path="docker/controller/Dockerfile.local"

if [ \$# -gt 1 ]; then
    if  [ "\$2" == "--build" ]; then # chain build.sh
        if [ ! -f "\${VERUS_DIR}/source/target-verus/release/verus" ]; then
            echo "Verus not found. Please set VERUS_DIR correct"
            exit 1
        fi
        build_controller="local"
    elif [ "\$2" == "--build-remote" ]; then
        build_controller="remote"
    fi
fi

case "\$build_controller" in
    local)
        echo "Building \$app controller binary"
        shift 2
        ./build.sh "\${app_filename}_controller.rs" "--no-verify" \$@
        echo "Building \$app controller image"
        docker build -f \$dockerfile_path -t local/\$app-controller:v0.1.0 --build-arg APP=\$app_filename .
        ;;
    remote)
        echo "Building \$app controller image using builder"
        dockerfile_path="docker/controller/Dockerfile.remote"
        docker build -f \$dockerfile_path -t local/\$app-controller:v0.1.0 --build-arg APP=\$app_filename .
        ;;
    no)
        echo "Use existing \$app controller image"
        ;;
esac

# for VDeployment, need to deploy VReplicaSet as a dependency
if [ "\$app" == "vdeployment" ]; then
    case "\$build_controller" in
        local)
            echo "Building vreplicaset controller binary"
            ./build.sh "vreplicaset_controller.rs" "--no-verify" \$@
            echo "Building vreplicaset controller image"
            docker build -f \$dockerfile_path -t local/vreplicaset-controller:v0.1.0 --build-arg APP=vreplicaset .
            ;;
        remote)
            echo "Building vreplicaset controller image using builder"
            dockerfile_path="docker/controller/Dockerfile.remote"
            docker build -f \$dockerfile_path -t local/vreplicaset-controller:v0.1.0 --build-arg APP=vreplicaset .
            ;;
        no)
            echo "Use existing vreplicaset controller image"
            ;;
    esac
fi

# Setup cluster, deploy the controller as a pod to the kind cluster, using the image just loaded
./deploy.sh \$app local
EOF

RUN <<EOF > verifiable-controllers/reproduce-verification-result.sh
#!/usr/bin/env bash

## Reproduce the verification result of the three controllers,
## also generate the Table 1 in the paper including:
## (1) the time spent on verifying each controller
## (2) the code size breakdown of each controller

set -xeu

YELLOW='\\033[1;33m'
GREEN='\\033[1;32m'
RED='\\033[0;31m'
NC='\\033[0m'

PREFIX="\${GREEN}"

CUR_DIR=\$(pwd)

echo -e "\${PREFIX}Verifying Anvil framework...\${NC}"
./build.sh anvil.rs --crate-type=lib --emit=dep-info --time --time-expanded --output-json --rlimit 50 > anvil.json

echo -e "\${PREFIX}Verifying Fluent controller...\${NC}"
./verify-controller-only.sh fluent

echo -e "\${PREFIX}Verifying RabbitMQ controller...\${NC}"
./verify-controller-only.sh rabbitmq

echo -e "\${PREFIX}Verifying ZooKeeper controller...\${NC}"
./verify-controller-only.sh zookeeper

echo -e "\${PREFIX}Calling Verus line counting tool...\${NC}"
pushd \$VERUS_DIR/source/tools/line_count
cargo run --release -- \$CUR_DIR/src/anvil.d > anvil_loc_table
cargo run --release -- \$CUR_DIR/src/fluent_controller.d > fluent_loc_table
cargo run --release -- \$CUR_DIR/src/rabbitmq_controller.d > rabbitmq_loc_table
cargo run --release -- \$CUR_DIR/src/zookeeper_controller.d > zookeeper_loc_table
popd

echo -e "\${PREFIX}Generating Table 1 to tools/t1.txt\${NC}"
cp anvil.json tools/anvil.json
cp fluent.json tools/fluent.json
cp rabbitmq.json tools/rabbitmq.json
cp zookeeper.json tools/zookeeper.json
pushd tools
python3 gen-t1.py > t1.txt
popd

echo -e "\${PREFIX}Presenting verification results from Verus. You should see 0 errors for Anvil and the three controllers, which means everything is verified.\${NC}"
cat anvil.json | grep "errors"
cat fluent.json | grep "errors"
cat rabbitmq.json | grep "errors"
cat zookeeper.json | grep "errors"

# echo -e "\${PREFIX}To check the verification time and code size results, just run cat tools/t1-time.txt and cat tools/t1-loc.txt.\${NC}"
EOF

RUN <<EOF > verifiable-controllers/verify-controller-only.sh
#!/usr/bin/env bash
set -xeu
app=\$1
./build.sh \${app}_controller.rs --time --time-expanded --output-json --rlimit 50 --verify-module \${app}_controller > \${app}.json
EOF

RUN <<EOF > verifiable-controllers/docker/verus/Dockerfile
FROM ubuntu:22.04

ARG VERUS_VER
WORKDIR /

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y git wget unzip curl gcc
RUN git clone https://github.com/verus-lang/verus.git \\
    && cd verus \\
    && git checkout \${VERUS_VER} \\
    && curl --proto '=https' --tlsv1.2 --retry 10 --retry-connrefused -fsSL "https://sh.rustup.rs" | sh -s -- --default-toolchain none -y \\
    && . "\$HOME/.cargo/env" \\
    && rustup toolchain install \\
    && cd source \\
    && ./tools/get-z3.sh \\
    && source ../tools/activate \\
    && vargo build --release
EOF

RUN <<EOF > verifiable-controllers/docker/controller/Dockerfile.remote
ARG BUILDER_IMAGE=verus-toolchain:local
FROM \${BUILDER_IMAGE} as builder

ARG APP
WORKDIR /anvil

SHELL ["/bin/bash", "-c"]

COPY . .

RUN apt-get update && apt-get install -y pkg-config libssl-dev

RUN . "\$HOME/.cargo/env" && VERUS_DIR=/verus ./build.sh \${APP}_controller.rs --no-verify --time
RUN mv /anvil/src/\${APP}_controller /anvil/src/controller

# =============================================================================

FROM ubuntu:22.04

COPY --from=builder /anvil/src/controller /usr/local/bin/controller

ENTRYPOINT ["/usr/local/bin/controller", "run"]
EOF

RUN <<EOF > verifiable-controllers/docker/controller/Dockerfile.local
FROM ubuntu:22.04

ARG APP
WORKDIR /

COPY src/\${APP}_controller /usr/local/bin/controller

ENTRYPOINT ["/usr/local/bin/controller", "run"]
EOF

RUN <<EOF > verifiable-controllers/deploy/kind.yaml
kind: Cluster
apiVersion: kind.x-k-s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
  - role: worker
featureGates:
  "StatefulSetAutoDeletePVC": true
EOF

RUN <<EOF > verifiable-controllers/e2e/Cargo.toml
[package]
name = "e2e_test"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html


[features]
default = ["openssl-tls", "kubederive", "ws", "latest", "runtime"]
kubederive = ["kube/derive"]
openssl-tls = ["kube/client", "kube/openssl-tls"]
rustls-tls = ["kube/client", "kube/rustls-tls"]
runtime = ["kube/runtime"]
ws = ["kube/ws"]
latest = ["k8s-openapi/v1_30"]


[dependencies]
tokio-util = "0.7.0"
futures = "0.3.17"
kube = { version = "0.91.0", default-features = false, features = ["admission"] }
kube-derive = { version = "0.91.0", default-features = false } # only needed to opt out of schema
kube-client = { version = "0.91.0", default-features = false }
kube-core = { version = "0.91.0", default-features = false }
k8s-openapi = { version = "0.22.0", default-features = false }
serde = { version = "1.0.130", features = ["derive"] }
serde_json = "1.0.68"
serde_yaml = "0.9.19"
tokio = { version = "1.14.0", features = ["full"] }
schemars = "0.8.6"
thiserror = "1.0.29"
tokio-stream = { version = "0.1.9", features = ["net"] }
zookeeper = "0.8"
tungstenite = "0.20.1"
tracing = "0.1.36"
tracing-subscriber = "0.3.17"
deps_hack = { path = "../src/deps_hack" }
EOF

# Create empty/placeholder files for source code and manifests
RUN touch verifiable-controllers/tools/gen-t1.py \
    verifiable-controllers/src/anvil.rs \
    verifiable-controllers/src/vreplicaset_controller.rs \
    verifiable-controllers/src/vdeployment_controller.rs \
    verifiable-controllers/src/vstatefulset_controller.rs \
    verifiable-controllers/src/vreplicaset_admission_controller.rs \
    verifiable-controllers/src/vdeployment_admission_controller.rs \
    verifiable-controllers/src/vstatefulset_admission_controller.rs \
    verifiable-controllers/src/zookeeper_controller.rs \
    verifiable-controllers/src/rabbitmq_controller.rs \
    verifiable-controllers/src/fluent_controller.rs \
    verifiable-controllers/src/deps_hack/src/lib.rs \
    verifiable-controllers/e2e/src/main.rs \
    verifiable-controllers/e2e/manifests/admission_server.yaml \
    verifiable-controllers/e2e/manifests/admission_webhooks.yaml

RUN for controller in vreplicaset vdeployment vstatefulset zookeeper rabbitmq fluent; do \
        mkdir -p verifiable-controllers/deploy/\${controller} && \
        touch verifiable-controllers/deploy/\${controller}/crd.yaml \
              verifiable-controllers/deploy/\${controller}/rbac.yaml \
              verifiable-controllers/deploy/\${controller}/deploy_local.yaml \
              verifiable-controllers/deploy/\${controller}/deploy_remote.yaml; \
    done

# Make all shell scripts executable
RUN chmod +x verifiable-controllers/build.sh \
    verifiable-controllers/deploy.sh \
    verifiable-controllers/local-test.sh \
    verifiable-controllers/reproduce-verification-result.sh \
    verifiable-controllers/verify-controller-only.sh

# Set the final working directory to the root of the repository
WORKDIR /home/cc/EnvGym/data/anvil/verifiable-controllers

# Set the default command to an interactive bash shell, providing a ready-to-use development environment
CMD ["/bin/bash"]