# Use the NVIDIA CUDA image as the base
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages for prcessing images - Commented out if not needed
RUN apt-get update && \
    apt-get install -y tzdata python3 python3-pip libgl1 libxext6 libxrender1 libsm6 libglib2.0-0 git curl wget && \
    rm -rf /var/lib/apt/lists/*

# Install Jupyter Notebook and JupyterHub
RUN pip3 install notebook jupyterhub jupyterlab-git

# Create a new user and set the permissions
RUN useradd -ms /bin/bash jupyteruser
RUN mkdir -p /workspace && chown -R jupyteruser:jupyteruser /workspace

# Create necessary directories with correct permissions
RUN mkdir -p /workspace/.local/share/jupyter && \
    mkdir -p /workspace/.jupyter && \
    chmod -R 777 /workspace/.local /workspace/.jupyter

# Set environment variables to use these directories
ENV JUPYTER_RUNTIME_DIR=/workspace/.local/share/jupyter/runtime
ENV JUPYTER_DATA_DIR=/workspace/.local/share/jupyter
ENV JUPYTER_CONFIG_DIR=/workspace/.jupyter

# Create or modify the Jupyter configuration file
RUN mkdir -p /workspace/.jupyter && \
    echo "c = get_config()" > /workspace/.jupyter/jupyter_notebook_config.py && \
    echo "c.ContentsManager.allow_hidden = True" >> /workspace/.jupyter/jupyter_notebook_config.py

# Set the working directory
WORKDIR /workspace

# Expose the port for Jupyter Notebook
EXPOSE 8888

# Switch to the new user
USER jupyteruser

# Command to run JupyterHub single-user server
CMD ["jupyterhub-singleuser", "--ip=0.0.0.0", "--allow-root"]
