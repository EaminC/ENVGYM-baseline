FROM ubuntu:20.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV RUST_VERSION=1.74.0
ENV PATH="/root/.cargo/bin:${PATH}"

RUN echo 'Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries
RUN echo 'Acquire::http::Timeout "120";' >> /etc/apt/apt.conf.d/80-retries
RUN echo 'Acquire::https::Timeout "120";' >> /etc/apt/apt.conf.d/80-retries

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get update --fix-missing

RUN apt-get install -y --fix-missing --no-install-recommends \
    build-essential \
    curl \
    git

RUN apt-get install -y --fix-missing --no-install-recommends \
    pkg-config \
    libssl-dev \
    cmake \
    ca-certificates

RUN apt-get install -y --fix-missing --no-install-recommends \
    libgit2-dev \
    libonig-dev \
    zlib1g-dev

RUN rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION}

RUN git clone https://github.com/sharkdp/bat.git /home/cc/EnvGym/data/sharkdp_bat

WORKDIR /home/cc/EnvGym/data/sharkdp_bat

RUN git submodule update --init --recursive

RUN cargo build --release --locked

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV PATH="/root/.cargo/bin:${PATH}"

RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries
RUN echo 'Acquire::http::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries
RUN echo 'Acquire::https::Timeout "300";' >> /etc/apt/apt.conf.d/80-retries

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get update --fix-missing || apt-get update

RUN apt-get install -y --fix-missing --no-install-recommends \
    git \
    curl \
    less \
    locales \
    ca-certificates

RUN apt-get install -y --fix-missing --no-install-recommends \
    libgit2-dev \
    libonig-dev \
    zlib1g-dev

RUN apt-get install -y --fix-missing --no-install-recommends \
    vim \
    nano || true

RUN rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

COPY --from=builder /home/cc/EnvGym/data/sharkdp_bat /home/cc/EnvGym/data/sharkdp_bat

WORKDIR /home/cc/EnvGym/data/sharkdp_bat

RUN cp target/release/bat /usr/local/bin/

RUN mkdir -p /home/cc/.config/bat/syntaxes /home/cc/.config/bat/themes /etc/bat \
    /usr/share/bash-completion/completions /usr/share/fish/vendor_completions.d \
    /usr/share/zsh/site-functions /usr/share/man/man1

RUN echo '--theme="TwoDark"\n--style=default\n--paging=always\n--pager="less -RF"' > /home/cc/.config/bat/config && \
    echo '--paging=always\n--pager="echo dummy-pager-from-system-config"' > /etc/bat/config

RUN cp assets/completions/bat.bash.in /usr/share/bash-completion/completions/bat && \
    cp assets/completions/bat.fish.in /usr/share/fish/vendor_completions.d/bat.fish && \
    cp assets/completions/bat.zsh.in /usr/share/zsh/site-functions/_bat && \
    cp assets/manual/bat.1.in /usr/share/man/man1/bat.1 && \
    gzip /usr/share/man/man1/bat.1

RUN echo 'export BAT_THEME_DARK="Dracula"\nexport BAT_THEME_LIGHT="GitHub"\nexport BAT_PAGER="less -RF"\nexport BAT_TABS=4\nexport MANPAGER="sh -c '\''col -bx | bat -l man -p'\''"' >> /root/.bashrc && \
    echo 'alias batgrep="batgrep --color"\nalias batman="batman"\nalias batdiff="git diff --name-only --relative --diff-filter=d | xargs bat --diff"' >> /root/.bashrc && \
    echo 'bathelp() { "$@" --help 2>&1 | bat --plain --language=help; }' >> /root/.bashrc

RUN bat cache --build || true

CMD ["/bin/bash"]