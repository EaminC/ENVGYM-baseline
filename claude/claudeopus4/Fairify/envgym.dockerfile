# Fairify Docker Environment
FROM python:3.7-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    bash \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace/Fairify

# Copy the entire repository
COPY . .

# Create and activate virtual environment, then install dependencies
RUN python3 -m venv fenv && \
    . fenv/bin/activate && \
    python3 -m pip install --upgrade pip && \
    pip install -r requirements.txt

# Make bash scripts executable
RUN chmod +x src/fairify.sh \
    stress/fairify-stress.sh \
    relaxed/fairify-relaxed.sh \
    targeted/fairify-targeted.sh \
    targeted2/fairify-targeted2.sh 2>/dev/null || true

# Set up environment to activate virtual environment on container start
RUN echo ". /workspace/Fairify/fenv/bin/activate" >> ~/.bashrc

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

# Start with bash shell at repository root
CMD ["/bin/bash"]