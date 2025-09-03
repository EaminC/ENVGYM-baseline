FROM python:3.7-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/cc/EnvGym/data/Fairify

COPY requirements.txt ./
RUN pip install --upgrade pip && \
    pip install tensorflow-cpu==2.5.0 && \
    pip install z3-solver && \
    pip install aif360 && \
    pip install numpy pandas scikit-learn matplotlib h5py jupyter && \
    pip install -r requirements.txt

COPY . .

RUN python -m venv fenv

RUN . fenv/bin/activate && \
    python -m pip install --upgrade pip && \
    pip install tensorflow-cpu==2.5.0 && \
    pip install z3-solver && \
    pip install aif360 && \
    pip install numpy pandas scikit-learn matplotlib h5py jupyter && \
    pip install -r requirements.txt

RUN mkdir -p logs results data/processed \
    src/AC/res src/GC/res src/BM/res \
    stress/AC/res stress/GC/res stress/BM/res \
    relaxed/AC/res relaxed/GC/res relaxed/BM/res \
    targeted/AC/res targeted/GC/res targeted/BM/res \
    targeted2/AC/res targeted2/GC/res targeted2/BM/res \
    src/AC/res-race src/AC/res-sex src/GC/res-sex

RUN for dir in src/AC/res src/GC/res src/BM/res \
    stress/AC/res stress/GC/res stress/BM/res \
    relaxed/AC/res relaxed/GC/res relaxed/BM/res \
    targeted/AC/res targeted/GC/res targeted/BM/res \
    targeted2/AC/res targeted2/GC/res targeted2/BM/res \
    src/AC/res-race src/AC/res-sex src/GC/res-sex; do \
    echo "Running the verification will produce result in \`csv\` files and save in this directory." > $dir/readme.md; \
    done

RUN find . -name "*.sh" -type f -exec chmod +x {} \;

RUN if [ ! -f .gitignore ]; then touch .gitignore; fi && \
    echo "*.DS_Store" >> .gitignore && \
    echo ".ipynb_checkpoints/" >> .gitignore && \
    echo "__pycache__/" >> .gitignore && \
    echo "~\$*" >> .gitignore && \
    echo "fenv/" >> .gitignore && \
    echo "*.pyc" >> .gitignore && \
    echo ".env" >> .gitignore && \
    echo "*.log" >> .gitignore && \
    echo "models/*.h5" >> .gitignore && \
    echo "data/*/processed/" >> .gitignore && \
    echo "res/" >> .gitignore && \
    echo "*.csv" >> .gitignore

RUN echo "#!/bin/bash" > /entrypoint.sh && \
    echo "cd /home/cc/EnvGym/data/Fairify" >> /entrypoint.sh && \
    echo "source fenv/bin/activate" >> /entrypoint.sh && \
    echo "exec /bin/bash" >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]