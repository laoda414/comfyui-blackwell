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
    python3.11 \
    python3.11-venv \
    python3-pip \
    git \
    wget \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

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

# Expose ComfyUI port
EXPOSE 8188

# Start ComfyUI with Blackwell-compatible settings
# Note: --disable-xformers is required as Flash Attention is not compatible with Blackwell
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--disable-xformers"]
