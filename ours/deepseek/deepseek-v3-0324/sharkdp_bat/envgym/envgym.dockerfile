FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV REPO_ROOT=/home/cc/EnvGym/data/sharkdp_bat
WORKDIR $REPO_ROOT

RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
    PyYAML \
    toml

RUN mkdir -p \
    $REPO_ROOT/tests/syntax-tests/source \
    $REPO_ROOT/tests/syntax-tests/highlighted \
    $REPO_ROOT/assets/syntaxes/02_Extra \
    $REPO_ROOT/doc \
    $REPO_ROOT/.github/ISSUE_TEMPLATE \
    $REPO_ROOT/src/syntax_mapping/builtins/platform_specific \
    $REPO_ROOT/tests/syntax_mapping \
    $REPO_ROOT/tests/syntax-tests/source/BatTestCustomAssets

RUN touch \
    $REPO_ROOT/doc/assets.md \
    $REPO_ROOT/.github/ISSUE_TEMPLATE/new-syntax-request.md \
    $REPO_ROOT/src/syntax_mapping/builtins/00-defaults.toml \
    $REPO_ROOT/src/syntax_mapping/builtins/99-overrides.toml

RUN touch \
    $REPO_ROOT/tests/syntax-tests/update.sh \
    $REPO_ROOT/tests/syntax-tests/create_highlighted_versions.py \
    $REPO_ROOT/tests/syntax-tests/regression_test.sh \
    $REPO_ROOT/tests/syntax-tests/compare_highlighted_versions.py \
    $REPO_ROOT/tests/syntax-tests/test_custom_assets.sh \
    $REPO_ROOT/tests/syntax-tests/BatTestCustomAssets.sublime-syntax \
    $REPO_ROOT/tests/syntax-tests/source/BatTestCustomAssets/NoColorsUnlessCustomAssetsAreUsed.battestcustomassets

RUN chmod +x \
    $REPO_ROOT/tests/syntax-tests/update.sh \
    $REPO_ROOT/tests/syntax-tests/regression_test.sh \
    $REPO_ROOT/tests/syntax-tests/test_custom_assets.sh

WORKDIR $REPO_ROOT
CMD ["/bin/bash"]