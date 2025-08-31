FROM ubuntu:20.04
WORKDIR /workspace
RUN apt-get update && apt-get install -y python3 python3-pip git
# Copy repository content
COPY . /workspace/
# Install python dependencies if requirements.txt exists
RUN if [ -f BCacheSim/install/requirements.txt ]; then \
      python3 -m pip install --user -r BCacheSim/install/requirements.txt; \
    fi
# Default entrypoint is a bash shell at the workspace root
ENTRYPOINT ["/bin/bash"]
