# Base image: Ubuntu 22.04 LTS (aligns with linux/amd64 requirement)
FROM ubuntu:22.04

# Set non-interactive mode for package installations to prevent prompts
ENV DEBIAN_FRONTEND=noninteractive

# Set environment variables for Deno installation path
ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

# Step 1: Install system packages, dependencies, Node.js, Firefox, and Thunderbird
RUN apt-get update && \
    # Install core utilities, Xvfb, browser dependencies, and software-properties-common for PPAs
    apt-get install -y \
    ca-certificates \
    curl \
    git \
    gnupg \
    lsb-release \
    software-properties-common \
    unzip \
    wget \
    xvfb \
    libasound2 \
    libatk1.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 && \
    # Add Mozilla PPA for latest Firefox and Thunderbird
    add-apt-repository ppa:mozillateam/ppa && \
    # Set up NodeSource repository for Node.js 18.x
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    # Update package list again and install applications
    apt-get update && \
    apt-get install -y nodejs firefox thunderbird && \
    # Clean up apt cache to reduce image size
    rm -rf /var/lib/apt/lists/*

# Step 2: Install Google Chrome (stable)
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb && \
    apt-get update && \
    apt-get install -y /tmp/chrome.deb && \
    rm /tmp/chrome.deb && \
    rm -rf /var/lib/apt/lists/*

# Step 3: Install Deno runtime
RUN curl -fsSL https://deno.land/x/install/install.sh | sh

# Step 4: Clone the project repository
WORKDIR /home/cc/EnvGym/data
RUN git clone https://github.com/darkreader/darkreader.git darkreader_darkreader

# Step 5: Set the working directory to the cloned repository
WORKDIR /home/cc/EnvGym/data/darkreader_darkreader

# Step 6: Install project dependencies using npm ci for a clean install
RUN npm ci

# Step 7: Run the Deno bootstrap script to generate required files
RUN npm run deno:bootstrap

# Step 8: Set the default command to launch a bash shell, ready for use
CMD ["/bin/bash"]