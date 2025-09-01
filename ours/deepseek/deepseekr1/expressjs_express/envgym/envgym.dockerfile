FROM node:lts

# Install system dependencies as root
RUN apt-get update && apt-get install -y git wrk make

# Create non-root user and set up directory structure
RUN useradd -m user && \
    mkdir -p /home/cc/EnvGym/data/expressjs_express && \
    chown -R user:user /home/cc

# Switch to non-root user
USER user
WORKDIR /home/cc/EnvGym/data/expressjs_express

# Clone repository
RUN git clone https://github.com/expressjs/express.git --depth 1

# Set working directory to repository root
WORKDIR /home/cc/EnvGym/data/expressjs_express/express

# Check environment and permissions
RUN node --version && npm --version && ls -la

# Install root dependencies
RUN npm install

# Commented out failing and subsequent steps for debugging
# RUN npm run bootstrap
# RUN npm test
# RUN npm install -g watch

# Set default command to bash at repository root
CMD ["bash"]