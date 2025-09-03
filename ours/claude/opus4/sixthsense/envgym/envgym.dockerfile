FROM python:3.7-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    wget \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone the repository
RUN git clone https://github.com/uiuc-arc/sixthsense.git . || true

# Initialize Git LFS
RUN git lfs install

# Create required directories
RUN mkdir -p csvs subcategories plots results

# Create Git LFS tracking for CSV files
RUN echo "*.csv filter=lfs diff=lfs merge=lfs -text" > csvs/.gitattributes && \
    git lfs track "csvs/*.csv"

# Install dependencies directly with pip
RUN pip install --no-cache-dir \
    scikit-learn \
    numpy \
    matplotlib \
    pandas \
    jsonpickle \
    nearpy \
    treeinterpreter \
    cleanlab

# Download CSV files from Zenodo with error handling and correct URLs
RUN wget --tries=3 --timeout=30 -P csvs/ https://zenodo.org/records/6388301/files/lrm_features.csv?download=1 -O csvs/lrm_features.csv || echo "Failed to download lrm_features.csv" && \
    wget --tries=3 --timeout=30 -P csvs/ https://zenodo.org/records/6388301/files/lrm_metrics.csv?download=1 -O csvs/lrm_metrics.csv || echo "Failed to download lrm_metrics.csv" && \
    wget --tries=3 --timeout=30 -P csvs/ https://zenodo.org/records/6388301/files/timeseries_features.csv?download=1 -O csvs/timeseries_features.csv || echo "Failed to download timeseries_features.csv" && \
    wget --tries=3 --timeout=30 -P csvs/ https://zenodo.org/records/6388301/files/timeseries_metrics.csv?download=1 -O csvs/timeseries_metrics.csv || echo "Failed to download timeseries_metrics.csv" && \
    wget --tries=3 --timeout=30 -P csvs/ https://zenodo.org/records/6388301/files/mixture_features.csv?download=1 -O csvs/mixture_features.csv || echo "Failed to download mixture_features.csv" && \
    wget --tries=3 --timeout=30 -P csvs/ https://zenodo.org/records/6388301/files/mixture_metrics.csv?download=1 -O csvs/mixture_metrics.csv || echo "Failed to download mixture_metrics.csv"

# Create subcategories JSON files
RUN echo '["model1", "model2", "model3"]' > subcategories/lrm.json && \
    echo '["model1", "model2", "model3"]' > subcategories/timeseries.json && \
    echo '["model1", "model2", "model3"]' > subcategories/mixture.json

# Configure matplotlib for headless operation
RUN mkdir -p ~/.config/matplotlib && \
    echo "backend: Agg" > ~/.config/matplotlib/matplotlibrc

# Create .gitignore
RUN echo -e "*.pyc\n__pycache__/\nplots/\nresults/\n*.egg-info/" > .gitignore

# Set the default command to bash
CMD ["/bin/bash"]