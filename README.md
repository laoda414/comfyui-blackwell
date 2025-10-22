# ComfyUI Docker Image for Blackwell GPU

A Docker image optimized for running ComfyUI on NVIDIA Blackwell architecture GPUs (RTX Pro 6000 and similar).

## What This Is

This Docker image provides a ready-to-use ComfyUI environment specifically configured for Blackwell GPUs (compute capability 12.0). It includes:

- CUDA 12.8 with cuDNN 9
- PyTorch nightly builds with CUDA 12.8 support
- ComfyUI with all dependencies
- Blackwell-specific optimizations and workarounds

## Key Features

- **Base Image**: `nvidia/cuda:12.8.0-cudnn9-devel-ubuntu24.04`
- **Python**: 3.12
- **PyTorch**: Nightly build with CUDA 12.8 support
- **Additional Libraries**: omegaconf, diffusers, opencv-python, matplotlib, evalidate
- **Optimized for**: Blackwell architecture (sm_120)

## Known Limitations

- **xFormers disabled**: Flash Attention is currently incompatible with Blackwell architecture, so the container runs with `--disable-xformers` flag
- This may result in slightly higher memory usage compared to older architectures with xFormers enabled

## Usage

### Prerequisites

- NVIDIA GPU with Blackwell architecture (e.g., RTX Pro 6000)
- Docker with NVIDIA Container Toolkit installed
- NVIDIA driver version 570+ (for Blackwell support)

### Running the Container

```bash
docker run -it --gpus all -p 8188:8188 dinoanderson777/comfyui-blackwell:latest
```

Once running, access ComfyUI at: `http://localhost:8188`

### Running on RunPod

1. Upload this image to Docker Hub (see Build Instructions below)
2. In RunPod, select "Custom Docker Image"
3. Enter your image name: `dinoanderson777/comfyui-blackwell:latest`
4. Configure ports: expose port 8188
5. Deploy and access via RunPod's provided URL

## Build Instructions

### Build Locally

```bash
docker build -t comfyui-blackwell:latest .
```

### Tag for Docker Hub

```bash
docker tag comfyui-blackwell:latest dinoanderson777/comfyui-blackwell:latest
```

### Push to Docker Hub

```bash
docker login
docker push dinoanderson777/comfyui-blackwell:latest
```

## Environment Variables

The following environment variables are pre-configured for optimal Blackwell performance:

- `PYTHONNOUSERSITE=1`: Prevents user site-packages conflicts
- `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`: Optimizes CUDA memory allocation
- `TORCH_CUDA_ARCH_LIST="12.0"`: Targets Blackwell architecture (compute capability 12.0)

## Technical Details

### Why CUDA 12.8?

Blackwell GPUs require CUDA 12.8 or newer for full feature support and optimal performance.

### Why PyTorch Nightly?

Stable PyTorch releases may not yet include full Blackwell support. Nightly builds ensure compatibility with the latest CUDA 12.8 features.

### Why Disable xFormers?

Flash Attention (used by xFormers) currently has compatibility issues with Blackwell architecture. The container uses standard attention mechanisms instead.

## Support

For issues related to:
- ComfyUI: https://github.com/comfyanonymous/ComfyUI
- This container: Open an issue in this repository

## License

This Dockerfile is provided as-is. ComfyUI and its dependencies retain their respective licenses.
