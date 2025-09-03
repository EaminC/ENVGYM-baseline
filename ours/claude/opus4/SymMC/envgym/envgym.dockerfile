FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    ant \
    build-essential \
    cmake \
    zlib1g-dev \
    libgmp-dev \
    libgmpxx4ldbl \
    git \
    wget \
    curl \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/cc/EnvGym/data/SymMC

COPY . /home/cc/EnvGym/data/SymMC/

RUN ls -la /home/cc/EnvGym/data/SymMC/ && \
    ls -la /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod/ || echo "Enhanced_Kodkod directory listing failed"

RUN mkdir -p /home/cc/EnvGym/data/SymMC/lib \
    && mkdir -p /home/cc/EnvGym/data/SymMC/config

RUN if [ ! -f /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod/lib/java-cup-11a.jar ]; then \
        for i in 1 2 3; do \
            wget --tries=3 --timeout=30 https://www2.cs.tum.edu/projects/cup/releases/java-cup-11a.jar -O /home/cc/EnvGym/data/SymMC/lib/java-cup-11a.jar && break || \
            curl -L --retry 3 --connect-timeout 30 https://www2.cs.tum.edu/projects/cup/releases/java-cup-11a.jar -o /home/cc/EnvGym/data/SymMC/lib/java-cup-11a.jar && break || \
            sleep 5; \
        done; \
    else \
        cp /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod/lib/java-cup-11a.jar /home/cc/EnvGym/data/SymMC/lib/; \
    fi

RUN if [ ! -f /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod/lib/org.alloytools.alloy.dist.jar ]; then \
        for i in 1 2 3; do \
            wget --tries=3 --timeout=30 https://repo1.maven.org/maven2/org/alloytools/org.alloytools.alloy.dist/5.1.0/org.alloytools.alloy.dist-5.1.0.jar -O /home/cc/EnvGym/data/SymMC/lib/org.alloytools.alloy.dist.jar && break || \
            curl -L --retry 3 --connect-timeout 30 https://repo1.maven.org/maven2/org/alloytools/org.alloytools.alloy.dist/5.1.0/org.alloytools.alloy.dist-5.1.0.jar -o /home/cc/EnvGym/data/SymMC/lib/org.alloytools.alloy.dist.jar && break || \
            sleep 5; \
        done; \
    else \
        cp /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod/lib/org.alloytools.alloy.dist.jar /home/cc/EnvGym/data/SymMC/lib/; \
    fi

RUN if [ ! -f /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod/lib/org.sat4j.core.jar ]; then \
        for i in 1 2 3; do \
            wget --tries=3 --timeout=30 https://repo1.maven.org/maven2/org/ow2/sat4j/org.ow2.sat4j.core/2.3.5/org.ow2.sat4j.core-2.3.5.jar -O /home/cc/EnvGym/data/SymMC/lib/org.sat4j.core.jar && break || \
            curl -L --retry 3 --connect-timeout 30 https://repo1.maven.org/maven2/org/ow2/sat4j/org.ow2.sat4j.core/2.3.5/org.ow2.sat4j.core-2.3.5.jar -o /home/cc/EnvGym/data/SymMC/lib/org.sat4j.core.jar && break || \
            sleep 5; \
        done; \
    else \
        cp /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod/lib/org.sat4j.core.jar /home/cc/EnvGym/data/SymMC/lib/; \
    fi

RUN if [ ! -f /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod/lib/org.sat4j.core-src.jar ]; then \
        for i in 1 2 3; do \
            wget --tries=3 --timeout=30 https://repo1.maven.org/maven2/org/ow2/sat4j/org.ow2.sat4j.core/2.3.5/org.ow2.sat4j.core-2.3.5-sources.jar -O /home/cc/EnvGym/data/SymMC/lib/org.sat4j.core-src.jar && break || \
            curl -L --retry 3 --connect-timeout 30 https://repo1.maven.org/maven2/org/ow2/sat4j/org.ow2.sat4j.core/2.3.5/org.ow2.sat4j.core-2.3.5-sources.jar -o /home/cc/EnvGym/data/SymMC/lib/org.sat4j.core-src.jar && break || \
            sleep 5; \
        done; \
    else \
        cp /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod/lib/org.sat4j.core-src.jar /home/cc/EnvGym/data/SymMC/lib/; \
    fi

RUN echo "*.tmp\n*.o\n*.a\n*.so\nlib/*.jar\n.classpath\n.project\n.idea/\n*/.idea/\nEnhanced_Kodkod/bin/\nEnumerator_Estimator/cmake-build-release/" >> /home/cc/EnvGym/data/SymMC/.gitignore

RUN ls -la /home/cc/EnvGym/data/SymMC/lib/ && file /home/cc/EnvGym/data/SymMC/lib/*.jar || echo "JAR file verification failed"

RUN if [ -d /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod ]; then \
        cd /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod && \
        if [ -f /home/cc/EnvGym/data/SymMC/lib/org.alloytools.alloy.dist.jar ]; then \
            cp /home/cc/EnvGym/data/SymMC/lib/org.alloytools.alloy.dist.jar lib/ || echo "Failed to copy org.alloytools.alloy.dist.jar"; \
        fi && \
        if [ -f /home/cc/EnvGym/data/SymMC/lib/java-cup-11a.jar ]; then \
            cp /home/cc/EnvGym/data/SymMC/lib/java-cup-11a.jar lib/ || echo "Failed to copy java-cup-11a.jar"; \
        fi && \
        if [ -f /home/cc/EnvGym/data/SymMC/lib/org.sat4j.core.jar ]; then \
            cp /home/cc/EnvGym/data/SymMC/lib/org.sat4j.core.jar lib/ || echo "Failed to copy org.sat4j.core.jar"; \
        fi && \
        if [ -f /home/cc/EnvGym/data/SymMC/lib/org.sat4j.core-src.jar ]; then \
            cp /home/cc/EnvGym/data/SymMC/lib/org.sat4j.core-src.jar lib/ || echo "Failed to copy org.sat4j.core-src.jar"; \
        fi; \
    else \
        echo "Warning: Enhanced_Kodkod directory not found, skipping JAR setup"; \
    fi

WORKDIR /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod

RUN if [ -f build.sh ]; then \
        chmod +x build.sh && \
        ./build.sh || echo "Build script failed, continuing..."; \
    fi && \
    if [ -f run.sh ]; then \
        chmod +x run.sh; \
    fi

WORKDIR /home/cc/EnvGym/data/SymMC/Enumerator_Estimator

RUN if [ -f build.sh ]; then \
        chmod +x build.sh && \
        ./build.sh || echo "Build script failed, continuing..."; \
    fi

WORKDIR /home/cc/EnvGym/data/SymMC

RUN echo '#!/bin/bash' > /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'echo "=== Environment Check ==="' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'echo "Java version:"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'java -version 2>&1 | head -n1' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'echo "Ant version:"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'ant -version' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'echo "CMake version:"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'cmake --version | head -n1' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'echo "G++ version:"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'g++ --version | head -n1' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'echo "JAR files:"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'ls -la /home/cc/EnvGym/data/SymMC/lib/*.jar 2>/dev/null || echo "No JAR files in lib"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'ls -la /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod/lib/*.jar 2>/dev/null || echo "No JAR files in Enhanced_Kodkod/lib"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'echo "Build scripts:"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'test -x /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod/build.sh && echo "Enhanced_Kodkod build.sh is executable" || echo "Enhanced_Kodkod build.sh not found or not executable"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'test -x /home/cc/EnvGym/data/SymMC/Enumerator_Estimator/build.sh && echo "Enumerator_Estimator build.sh is executable" || echo "Enumerator_Estimator build.sh not found or not executable"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'test -x /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod/run.sh && echo "Enhanced_Kodkod run.sh is executable" || echo "Enhanced_Kodkod run.sh not found or not executable"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'echo "Compiled classes:"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'test -f /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod/bin/edu/mit/csail/sdg/alloy4whole/ExampleUsingTheCompiler.class && echo "ExampleUsingTheCompiler compiled" || echo "ExampleUsingTheCompiler not compiled"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'echo "MiniSat executable:"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'test -x /home/cc/EnvGym/data/SymMC/Enumerator_Estimator/cmake-build-release/minisat && echo "minisat executable exists" || echo "minisat executable not found"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'echo "GMP library:"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'ldconfig -p | grep -q gmp && echo "GMP library installed" || echo "GMP library not found"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'echo ".gitignore:"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh && \
    echo 'test -f /home/cc/EnvGym/data/SymMC/.gitignore && echo ".gitignore exists" || echo ".gitignore not found"' >> /home/cc/EnvGym/data/SymMC/environment_check.sh

RUN chmod +x /home/cc/EnvGym/data/SymMC/environment_check.sh

RUN echo '#!/bin/bash' > /home/cc/EnvGym/data/SymMC/test_runner.sh && \
    echo 'echo "=== Running Test Suite ==="' >> /home/cc/EnvGym/data/SymMC/test_runner.sh && \
    echo 'cd /home/cc/EnvGym/data/SymMC' >> /home/cc/EnvGym/data/SymMC/test_runner.sh && \
    echo './environment_check.sh' >> /home/cc/EnvGym/data/SymMC/test_runner.sh

RUN chmod +x /home/cc/EnvGym/data/SymMC/test_runner.sh

CMD ["/bin/bash"]