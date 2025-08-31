FROM node:20-bullseye

# Set working directory to repo root
WORKDIR /darkreader_darkreader

# Copy all contents to container
COPY . /darkreader_darkreader

# Install dependencies
RUN npm install

# Default to bash CLI at repo root
CMD ["/bin/bash"]
