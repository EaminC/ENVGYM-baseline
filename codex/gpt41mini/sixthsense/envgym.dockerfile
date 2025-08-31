FROM python:3.7-slim
WORKDIR /app
COPY . /app
RUN pip install --no-cache-dir -r requirements.txt && mkdir -p plots models results
CMD ["/bin/bash"]
