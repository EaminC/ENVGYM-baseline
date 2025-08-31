FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash \
    curl \
    wget \
    gnupg2 \
    ruby \
    ruby-dev \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install bundler
RUN gem install bundler

# Copy the entire repository into the image
COPY . /app

# Install gems based on Gemfile.template
RUN if [ -f Gemfile.template ]; then \
      mv Gemfile.template Gemfile && \
      bundle install --jobs 4 --retry 3; \
    fi

# Default to bash shell
CMD ["/bin/bash"]
