FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN apt-get update && \
    apt-get install -y g++ make libopenmpi-dev python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"
CMD ["/bin/bash"]