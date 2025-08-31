FROM python:3.7-slim
WORKDIR /Fairify
COPY . .
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && \
    python3 -m pip install --upgrade pip && \
    pip install -r requirements.txt && \
    apt-get purge -y --auto-remove build-essential && \
    rm -rf /var/lib/apt/lists/*
CMD ["/bin/bash"]

