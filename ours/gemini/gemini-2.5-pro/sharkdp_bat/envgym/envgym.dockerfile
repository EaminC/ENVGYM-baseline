# STAGE 1: Build Environment
# Use the specified Rust version as the base image. This includes Debian and build tools.
FROM rust:1.74 AS builder

# Set environment variables to non-interactive to prevent prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install all necessary build-time dependencies as outlined in the plan
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    cmake \
    libssl-dev \
    zlib1g-dev \
    git \
    jq \
    patch \
    bash \
    sed && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory for the build
WORKDIR /build

# Copy the entire project source code into the container
# This assumes the Docker build context is the root of the repository
COPY . .

# Initialize and fetch all git submodules required for syntaxes and themes
# This is a critical step before generating assets
RUN git submodule update --init --recursive

# Compile the application and generate all assets in a single step.
# The `build-assets` feature flag enables the build script that creates
# man pages, shell completions, and other necessary assets.
# This replaces the failing script call and the redundant, separate build command.
RUN cargo build --release --locked --features=build-assets

# --- STAGE 2: Final Runtime Image ---
# Start from a minimal Debian base image for a small footprint
FROM debian:12-slim

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install only the required runtime dependencies and recommended tools
# This includes shared libraries for bat, a pager, man page support, and bash completion.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libssl3 \
    zlib1g \
    ca-certificates \
    less \
    man-db \
    bash-completion && \
    rm -rf /var/lib/apt/lists/*

# Copy the compiled 'bat' binary from the builder stage to a standard location in the PATH
COPY --from=builder /build/target/release/bat /usr/local/bin/bat

# Copy the generated man page and update the man-db index so 'man bat' works
COPY --from=builder /build/target/release/build/bat-*/out/bat.1 /usr/local/share/man/man1/bat.1
RUN mandb

# Create directories for shell completions that might not exist on a minimal image
RUN mkdir -p /usr/local/share/zsh/site-functions /usr/share/fish/vendor_completions.d

# Copy the generated shell completion scripts to their standard system locations
COPY --from=builder /build/target/release/build/bat-*/out/bat.bash /usr/share/bash-completion/completions/bat
COPY --from=builder /build/target/release/build/bat-*/out/_bat /usr/local/share/zsh/site-functions/_bat
COPY --from=builder /build/target/release/build/bat-*/out/bat.fish /usr/share/fish/vendor_completions.d/bat.fish

# Create the system-wide configuration directory as specified in the plan
RUN mkdir -p /etc/bat

# Create a default system-wide configuration file with sensible defaults
COPY <<EOF /etc/bat/config
# Default system-wide bat config created by Dockerfile
# This can be overridden by user-specific config or command-line flags.

# Set a default theme. Use `bat --list-themes` to see all options.
--theme="TwoDark"

# Show line numbers, Git modifications, and file header.
--style="numbers,changes,header"

# Enable this to use italic text on compatible terminals.
--italic-text=always
EOF

# Create a shell profile script to set up aliases and environment variables for all users
COPY <<EOF /etc/profile.d/bat.sh
# Set environment variables for bat. These can be overridden by users.
export BAT_THEME="OneHalfDark"

# Alias 'cat' to 'bat' for convenience in interactive shells.
# The --paging=never option mimics 'cat' behavior for piped output.
alias cat='bat --paging=never'
EOF

# Set the final working directory for interactive sessions
WORKDIR /root

# Fulfill the user request to be put in a bash CLI setting.
# The 'bat' application is now fully installed and configured system-wide.
CMD ["/bin/bash"]