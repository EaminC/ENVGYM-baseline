FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y g++ g++-9 cmake python3 make wget libbenchmark-dev valgrind nodejs npm ninja-build && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9

WORKDIR /simdjson

COPY . .

# Build with CMake and Ninja for parallel compilation
RUN mkdir -p build && cd build && \
    cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DSIMDJSON_DEVELOPER_MODE=ON .. && \
    ninja -j $(nproc)

# Validation script with Valgrind checks
RUN echo $'#!/bin/bash\n\
echo "=== Validation Tests ===\n" && \
echo "Running quickstart..." && ./build/examples/quickstart/quickstart && \
echo "\nRunning quickstart under Valgrind..." && valgrind --leak-check=full --error-exitcode=1 ./build/examples/quickstart/quickstart && \
echo "\nRunning amalgamate_demo..." && ./build/singleheader/amalgamate_demo && \
echo "\nRunning amalgamate_demo under Valgrind..." && valgrind --leak-check=full --error-exitcode=1 ./build/singleheader/amalgamate_demo && \
echo "\nRunning bench_dom_api (short)..." && ./build/benchmark/bench_dom_api --benchmark_min_time=0.1 && \
echo "\nValidation successful"' > /validate.sh && \
chmod +x /validate.sh

# Set bash as default with validation hint
CMD ["/bin/bash", "-c", "echo 'Run /validate.sh to test'; /bin/bash"]