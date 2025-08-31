FROM ubuntu:22.04
RUN apt-get update && apt-get install -y build-essential cmake python3 python3-pip git
RUN python3 -m pip install conan
WORKDIR /Catch2
COPY . .
RUN conan install . && cmake . && cmake --build . && cmake --install .
CMD ["/bin/bash"]
