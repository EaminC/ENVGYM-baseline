# Specifies the target platform for the build, ensuring consistency with the plan.
# Use the official Node.js LTS (Long Term Support) image as the base.
FROM --platform=linux/amd64 node:lts-bullseye

# Set environment variables. NODE_OPTIONS is included to maintain compatibility
# with older crypto dependencies in build tools on newer Node.js versions, as per the plan.
ENV NODE_OPTIONS=--openssl-legacy-provider

# Install git, a required dependency for version control and semantic-release.
# Clean up the apt cache afterward to minimize image size.
RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory for the application inside the container.
WORKDIR /usr/src/app

# Copy package management files first to leverage Docker's build cache.
# The 'npm ci' step will only be re-run if these files change.
COPY package*.json ./

# Install project dependencies using 'npm ci' for a clean, reproducible build
# from the package-lock.json file, as recommended in the setup plan.
RUN npm ci

# Copy all remaining project files, including source code, configuration files,
# and CI workflows, into the working directory.
COPY . .

# The base node image includes a non-root 'node' user.
# Change the ownership of the application files to this user for better security.
RUN chown -R node:node .

# Switch the context to run subsequent commands as the non-root 'node' user.
USER node

# Set the default command to start a bash shell. This places the user in an
# interactive CLI at the project root with the environment fully installed and ready to use.
CMD ["/bin/bash"]