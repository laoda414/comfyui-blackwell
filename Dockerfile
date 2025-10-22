# ComfyUI Docker Image for Blackwell GPU (NVIDIA RTX Pro 6000)
# Base image with CUDA 12.8.1 and cuDNN for Blackwell architecture support
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

# Set environment variables for Blackwell optimization
ENV PYTHONNOUSERSITE=1
ENV PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
ENV TORCH_CUDA_ARCH_LIST="12.0"
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    bash \
    python3.11 \
    python3.11-venv \
    python3-pip \
    git \
    wget \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set shell environment variable for JupyterLab terminal
ENV SHELL=/bin/bash

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install PyTorch nightly with CUDA 12.8 support
RUN pip install --no-cache-dir \
    torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/nightly/cu128

# Set working directory
WORKDIR /app

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app/ComfyUI

# Clone ComfyUI Manager into custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git /app/ComfyUI/custom_nodes/ComfyUI-Manager

# Install ComfyUI requirements
WORKDIR /app/ComfyUI
RUN pip install --no-cache-dir -r requirements.txt

# Install additional dependencies
RUN pip install --no-cache-dir \
    omegaconf \
    diffusers \
    opencv-python \
    matplotlib \
    evalidate

# Install JupyterLab and ipykernel
RUN pip install --no-cache-dir jupyterlab ipykernel ipython

# Register Python kernel with Jupyter
RUN python3 -m ipykernel install --user --name python3 --display-name "Python 3"

# Verify kernel installation
RUN jupyter kernelspec list

# Configure JupyterLab terminal to use bash
RUN mkdir -p /root/.jupyter && \
    echo "c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}" > /root/.jupyter/jupyter_lab_config.py

# Verify bash is accessible
RUN which bash && bash --version

# Expose ports for ComfyUI and JupyterLab
EXPOSE 8188
EXPOSE 8888

# Create ComfyUI startup helper script
RUN echo '#!/bin/bash\n\
cd /app/ComfyUI\n\
python3 main.py --listen 0.0.0.0 --disable-xformers "$@"\n\
' > /app/start_comfyui.sh && chmod +x /app/start_comfyui.sh

# Start JupyterLab by default (ComfyUI can be started manually from terminal)
# Note: --disable-xformers is required as Flash Attention is not compatible with Blackwell
# CORS settings allow access from Cloud Shell Web Preview and RunPod
CMD ["jupyter", "lab", \
     "--ip=0.0.0.0", \
     "--port=8888", \
     "--no-browser", \
     "--allow-root", \
     "--NotebookApp.token=", \
     "--NotebookApp.password=", \
     "--ServerApp.allow_origin=*", \
     "--ServerApp.allow_remote_access=True", \
     "--ServerApp.disable_check_xsrf=True"]
