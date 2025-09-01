# Use a modern, slim, and platform-compatible Python base image
FROM --platform=linux/amd64 python:3.10-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file first to leverage Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application source code
COPY . .

# Create directories for outputs and data
RUN mkdir -p plots models results csvs

# Copy pre-downloaded datasets into the image
COPY csvs/ ./csvs/

# Set the default command to an interactive bash shell
CMD ["/bin/bash"]