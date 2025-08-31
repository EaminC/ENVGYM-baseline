# Development dockerfile for Nushell
# This dockerfile builds Nushell from source and provides a bash environment
# Build: docker build -f envgym.dockerfile -t nushell-dev .
# Run: docker run -it nushell-dev

FROM rust:1.87.0-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    git \
    curl \
    vim \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy the entire repository
COPY . .

# Build Nushell
RUN cargo build --release --locked

# Install Nushell to /usr/local/bin
RUN cp target/release/nu /usr/local/bin/nu && \
    chmod +x /usr/local/bin/nu

# Add nu to shells
RUN echo '/usr/local/bin/nu' >> /etc/shells

# Set bash as the default shell for this development environment
SHELL ["/bin/bash", "-c"]

# Set environment variables
ENV PATH="/usr/local/bin:${PATH}"

# Create a default nushell config directory
RUN mkdir -p /root/.config/nushell

# Set the working directory to the repository root
WORKDIR /workspace

# Start with bash as requested
CMD ["/bin/bash"]