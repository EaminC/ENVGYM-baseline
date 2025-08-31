FROM openjdk:17

RUN apt-get update && apt-get install -y python3 python3-pip maven && \
    python3 -m pip install --upgrade pip pytest && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

RUN mvn clean install -DskipTests

ENTRYPOINT ["/bin/bash"]
