FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y curl unzip zip git subversion software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y python3.11 python3.11-dev python3.11-venv

ENV SDKMAN_DIR=/root/.sdkman \
    SDKMAN_NONINTERACTIVE=true

RUN curl -s "https://get.sdkman.io" | bash && \
    . "$SDKMAN_DIR/bin/sdkman-init.sh" && \
    sdk install java 23.0.1-graal && \
    sdk install maven && \
    $SDKMAN_DIR/candidates/java/current/bin/gu install python

ENV GRAALVM_HOME="$SDKMAN_DIR/candidates/java/current" \
    JAVA_HOME="$GRAALVM_HOME" \
    MAVEN_HOME="$SDKMAN_DIR/candidates/maven/current" \
    PATH="$GRAALVM_HOME/bin:$MAVEN_HOME/bin:$PATH"

RUN python3.11 -m pip install pytest

COPY . /app
WORKDIR /app

RUN chmod +x run.sh

CMD ["/bin/bash"]