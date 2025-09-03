FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /home/cc/EnvGym/data

# Clone TabPFN repository
RUN git clone https://github.com/priorlabs/tabpfn.git --depth 1 TabPFN

# Set working directory to TabPFN
WORKDIR /home/cc/EnvGym/data/TabPFN

# Initialize git submodules
RUN git submodule update --init --recursive

# Create virtual environment
RUN python -m venv /home/cc/EnvGym/data/TabPFN/venv

# Activate virtual environment and upgrade pip
RUN /home/cc/EnvGym/data/TabPFN/venv/bin/pip install --upgrade pip setuptools wheel

# Install uv
RUN /home/cc/EnvGym/data/TabPFN/venv/bin/pip install uv

# Install CPU-only PyTorch
RUN /home/cc/EnvGym/data/TabPFN/venv/bin/pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Install TabPFN without dependencies
RUN /home/cc/EnvGym/data/TabPFN/venv/bin/pip install --no-deps .

# Install core dependencies
RUN /home/cc/EnvGym/data/TabPFN/venv/bin/pip install \
    "scikit-learn>=1.2.0,<1.7" \
    "pandas>=1.4.0,<3" \
    "scipy>=1.11.1,<2" \
    "einops>=0.2.0,<0.9" \
    "huggingface-hub" \
    "pydantic>=2.8.0" \
    "pydantic-settings>=2.0.0" \
    "python-dotenv" \
    "typing-extensions"

# Install test dependencies
RUN /home/cc/EnvGym/data/TabPFN/venv/bin/pip install pytest pytest-xdist psutil

# Install development dependencies
RUN /home/cc/EnvGym/data/TabPFN/venv/bin/pip install \
    "ruff==0.8.6" \
    "mypy==1.17.0" \
    "pre-commit" \
    "commitizen" \
    "types-pyyaml" \
    "types-psutil" \
    "pyright" \
    "onnx"

# Create .env file
RUN echo '# TabPFN Settings\n\
TABPFN_MODEL_CACHE_DIR=/home/cc/EnvGym/data/TabPFN/models\n\
TABPFN_ALLOW_CPU_LARGE_DATASET=true\n\
TABPFN_EXCLUDE_DEVICES=cuda,mps\n\
\n\
# PyTorch Settings\n\
PYTORCH_CUDA_ALLOC_CONF=\n\
CUDA_VISIBLE_DEVICES=\n\
\n\
# Testing Settings\n\
FORCE_CONSISTENCY_TESTS=0\n\
CI=false' > .env

# Create .gemini directory and config
RUN mkdir -p .gemini && \
    echo 'code_review:\n\
  pull_request_opened:\n\
    summary: false' > .gemini/config.yaml

# Create scripts directory and generate_dependencies.py
RUN mkdir -p scripts && \
    echo '#!/usr/bin/env python3' > scripts/generate_dependencies.py && \
    echo 'import sys' >> scripts/generate_dependencies.py && \
    echo 'import re' >> scripts/generate_dependencies.py && \
    echo 'from pathlib import Path' >> scripts/generate_dependencies.py && \
    echo '' >> scripts/generate_dependencies.py && \
    echo 'def parse_pyproject_toml():' >> scripts/generate_dependencies.py && \
    echo '    """Parse pyproject.toml and extract dependencies."""' >> scripts/generate_dependencies.py && \
    echo '    pyproject_path = Path("pyproject.toml")' >> scripts/generate_dependencies.py && \
    echo '    if not pyproject_path.exists():' >> scripts/generate_dependencies.py && \
    echo '        print("pyproject.toml not found")' >> scripts/generate_dependencies.py && \
    echo '        sys.exit(1)' >> scripts/generate_dependencies.py && \
    echo '    ' >> scripts/generate_dependencies.py && \
    echo '    content = pyproject_path.read_text()' >> scripts/generate_dependencies.py && \
    echo '    ' >> scripts/generate_dependencies.py && \
    echo '    # Extract dependencies section' >> scripts/generate_dependencies.py && \
    echo '    deps_match = re.search(r"dependencies = \[(.*?)\]", content, re.DOTALL)' >> scripts/generate_dependencies.py && \
    echo '    if not deps_match:' >> scripts/generate_dependencies.py && \
    echo '        print("No dependencies found")' >> scripts/generate_dependencies.py && \
    echo '        return []' >> scripts/generate_dependencies.py && \
    echo '    ' >> scripts/generate_dependencies.py && \
    echo '    deps_text = deps_match.group(1)' >> scripts/generate_dependencies.py && \
    echo '    deps = re.findall(r'"'"'"([^"]+)"'"'"', deps_text)' >> scripts/generate_dependencies.py && \
    echo '    return deps' >> scripts/generate_dependencies.py && \
    echo '' >> scripts/generate_dependencies.py && \
    echo 'def generate_minimum_requirements(deps):' >> scripts/generate_dependencies.py && \
    echo '    """Generate requirements with minimum versions."""' >> scripts/generate_dependencies.py && \
    echo '    min_reqs = []' >> scripts/generate_dependencies.py && \
    echo '    for dep in deps:' >> scripts/generate_dependencies.py && \
    echo '        if ">=" in dep:' >> scripts/generate_dependencies.py && \
    echo '            # Keep minimum version' >> scripts/generate_dependencies.py && \
    echo '            min_reqs.append(dep.split(",")[0])' >> scripts/generate_dependencies.py && \
    echo '        else:' >> scripts/generate_dependencies.py && \
    echo '            min_reqs.append(dep)' >> scripts/generate_dependencies.py && \
    echo '    return min_reqs' >> scripts/generate_dependencies.py && \
    echo '' >> scripts/generate_dependencies.py && \
    echo 'def generate_maximum_requirements(deps):' >> scripts/generate_dependencies.py && \
    echo '    """Generate requirements with maximum versions."""' >> scripts/generate_dependencies.py && \
    echo '    max_reqs = []' >> scripts/generate_dependencies.py && \
    echo '    for dep in deps:' >> scripts/generate_dependencies.py && \
    echo '        if "<" in dep:' >> scripts/generate_dependencies.py && \
    echo '            # Extract package name and max version' >> scripts/generate_dependencies.py && \
    echo '            parts = dep.split(">")' >> scripts/generate_dependencies.py && \
    echo '            if len(parts) > 1:' >> scripts/generate_dependencies.py && \
    echo '                pkg_name = parts[0]' >> scripts/generate_dependencies.py && \
    echo '                max_part = dep.split("<")[-1]' >> scripts/generate_dependencies.py && \
    echo '                max_version = max_part.strip()' >> scripts/generate_dependencies.py && \
    echo '                # Convert < to ==' >> scripts/generate_dependencies.py && \
    echo '                if max_version:' >> scripts/generate_dependencies.py && \
    echo '                    max_reqs.append(f"{pkg_name}=={max_version}")' >> scripts/generate_dependencies.py && \
    echo '                else:' >> scripts/generate_dependencies.py && \
    echo '                    max_reqs.append(dep)' >> scripts/generate_dependencies.py && \
    echo '            else:' >> scripts/generate_dependencies.py && \
    echo '                max_reqs.append(dep)' >> scripts/generate_dependencies.py && \
    echo '        else:' >> scripts/generate_dependencies.py && \
    echo '            max_reqs.append(dep)' >> scripts/generate_dependencies.py && \
    echo '    return max_reqs' >> scripts/generate_dependencies.py && \
    echo '' >> scripts/generate_dependencies.py && \
    echo 'def main():' >> scripts/generate_dependencies.py && \
    echo '    if len(sys.argv) != 2 or sys.argv[1] not in ["minimum", "maximum"]:' >> scripts/generate_dependencies.py && \
    echo '        print("Usage: python generate_dependencies.py [minimum|maximum]")' >> scripts/generate_dependencies.py && \
    echo '        sys.exit(1)' >> scripts/generate_dependencies.py && \
    echo '    ' >> scripts/generate_dependencies.py && \
    echo '    mode = sys.argv[1]' >> scripts/generate_dependencies.py && \
    echo '    deps = parse_pyproject_toml()' >> scripts/generate_dependencies.py && \
    echo '    ' >> scripts/generate_dependencies.py && \
    echo '    if mode == "minimum":' >> scripts/generate_dependencies.py && \
    echo '        reqs = generate_minimum_requirements(deps)' >> scripts/generate_dependencies.py && \
    echo '        output_file = "requirements-minimum.txt"' >> scripts/generate_dependencies.py && \
    echo '    else:' >> scripts/generate_dependencies.py && \
    echo '        reqs = generate_maximum_requirements(deps)' >> scripts/generate_dependencies.py && \
    echo '        output_file = "requirements-maximum.txt"' >> scripts/generate_dependencies.py && \
    echo '    ' >> scripts/generate_dependencies.py && \
    echo '    with open(output_file, "w") as f:' >> scripts/generate_dependencies.py && \
    echo '        for req in reqs:' >> scripts/generate_dependencies.py && \
    echo '            f.write(req + "\\n")' >> scripts/generate_dependencies.py && \
    echo '    ' >> scripts/generate_dependencies.py && \
    echo '    print(f"Generated {output_file}")' >> scripts/generate_dependencies.py && \
    echo '' >> scripts/generate_dependencies.py && \
    echo 'if __name__ == "__main__":' >> scripts/generate_dependencies.py && \
    echo '    main()' >> scripts/generate_dependencies.py

RUN chmod +x scripts/generate_dependencies.py

# Set up bash environment
RUN echo 'export PATH=/home/cc/EnvGym/data/TabPFN/venv/bin:$PATH' >> ~/.bashrc

# Set default command to bash
CMD ["/bin/bash"]