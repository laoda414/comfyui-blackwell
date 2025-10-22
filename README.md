# ComfyUI Docker Image for Blackwell GPU

A Docker image optimized for running ComfyUI on NVIDIA Blackwell architecture GPUs (RTX Pro 6000 and similar).

## What This Is

This Docker image provides a ready-to-use ComfyUI environment specifically configured for Blackwell GPUs (compute capability 12.0). It includes:

- CUDA 12.8.1 with cuDNN
- PyTorch nightly builds with CUDA 12.8 support
- ComfyUI with all dependencies
- **ComfyUI Manager** pre-installed for easy custom node management
- **JupyterLab** for browser-based development and file editing
- Blackwell-specific optimizations and workarounds

## Key Features

- **Base Image**: `nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04`
- **Python**: 3.11
- **PyTorch**: Nightly build with CUDA 12.8 support
- **ComfyUI Manager**: Pre-installed for easy custom node installation via UI
- **JupyterLab**: Optional browser-based development environment (port 8888)
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

**Start the container:**
```bash
docker run -d --gpus all -p 8188:8188 -p 8888:8888 --name comfyui dinoanderson777/comfyui-blackwell:latest
```

**Access JupyterLab:**
- Open browser: `http://localhost:8888`
- JupyterLab starts automatically and keeps the container alive

**Start ComfyUI from JupyterLab terminal:**

Option 1: Using helper script (recommended)
```bash
/app/start_comfyui.sh
```

Option 2: With custom flags
```bash
/app/start_comfyui.sh --gpu-only --highvram
```

Option 3: Manual command
```bash
cd /app/ComfyUI
python3 main.py --listen 0.0.0.0 --disable-xformers
```

**Access the services:**
- JupyterLab: `http://localhost:8888`
- ComfyUI (after starting): `http://localhost:8188`

**Note**: JupyterLab runs without authentication by default. For production use, configure proper authentication.

**Benefits of this approach:**
- ✅ Full control over when ComfyUI starts
- ✅ Can download models before starting ComfyUI
- ✅ Can test different startup flags easily
- ✅ Can restart ComfyUI without restarting container
- ✅ Can check logs and debug before starting
- ✅ JupyterLab keeps container alive for management tasks

### Running on RunPod

1. Upload this image to Docker Hub (see Build Instructions below)
2. In RunPod, select "Custom Docker Image"
3. Enter your image name: `dinoanderson777/comfyui-blackwell:latest`
4. Configure ports:
   - Port 8888 (JupyterLab)
   - Port 8188 (ComfyUI)
5. Deploy and access JupyterLab via RunPod's provided URL
6. Open terminal in JupyterLab and run `/app/start_comfyui.sh` to start ComfyUI
7. Access ComfyUI through port 8188

### ComfyUI Manager Features

This image includes **ComfyUI Manager** pre-installed, which provides:

- ✅ **Browse & Install Custom Nodes**: Access hundreds of custom nodes via the UI
- ✅ **One-Click Installation**: Install nodes and their dependencies automatically
- ✅ **Update Management**: Keep your custom nodes up to date
- ✅ **Model Manager**: Download models directly from the UI
- ✅ **Workflow Sharing**: Import workflows with automatic node installation

Access ComfyUI Manager through the "Manager" button in the ComfyUI interface.

### JupyterLab Features

When enabled with `JUPYTER_ENABLE=1`, JupyterLab provides:

- ✅ **Browser-Based Terminal**: Full bash terminal access
- ✅ **File Editor**: Edit Python scripts, configs, and workflows
- ✅ **Notebook Support**: Create and run Jupyter notebooks
- ✅ **No SSH Required**: Everything accessible via web browser

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
