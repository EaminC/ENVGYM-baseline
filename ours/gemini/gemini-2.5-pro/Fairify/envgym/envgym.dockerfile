# Use the official Python 3.7 image as the base
FROM python:3.7-slim

# Set the working directory inside the container
WORKDIR /app

# Install C++ build tools required for some Python packages
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && \
    rm -rf /var/lib/apt/lists/*

# Copy only the requirements file first to leverage Docker layer caching
COPY requirements.txt ./

# Upgrade pip and install the Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the entire project context into the working directory
COPY . .

# Make all shell scripts in the project executable
RUN find . -name "*.sh" -exec chmod +x {} \;

# Set the default command to start a bash shell for interactive use
CMD ["/bin/bash"]