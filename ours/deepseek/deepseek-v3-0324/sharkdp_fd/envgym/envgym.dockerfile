FROM rust:1.64-slim-bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
    make \
    git \
    bash-completion \
    jq \
    fish \
    zsh \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN cargo build --release \
    && mkdir -p /usr/share/zsh/vendor-completions \
    && mkdir -p /usr/local/share/man/man1 \
    && [ -f contrib/completion/_fd ] && cp contrib/completion/_fd /usr/share/zsh/vendor-completions/ || true \
    && [ -f doc/fd.1 ] && cp doc/fd.1 /usr/local/share/man/man1/ || true

RUN mkdir -p ~/.config/fd \
    && touch ~/.fdignore ~/.config/fd/ignore

ENV FZF_DEFAULT_COMMAND='fd --type file' \
    FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND" \
    LS_COLORS=$(ls --color=always)

RUN echo "alias fd='fdfind'" >> ~/.bashrc \
    && echo "alias fd='fdfind'" >> ~/.zshrc

WORKDIR /app
CMD ["/bin/bash"]