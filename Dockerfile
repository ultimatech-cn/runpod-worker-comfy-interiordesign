# Use Nvidia CUDA base image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 as base

# Prevents prompts from packages asking for user input during installation
ENV DEBIAN_FRONTEND=noninteractive
# Prefer binary wheels over source distributions for faster pip installations
ENV PIP_PREFER_BINARY=1
# Ensures output from python is printed immediately to the terminal without buffering
ENV PYTHONUNBUFFERED=1 

# Install Python, git and other necessary tools
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    wget

# Clean up to reduce image size
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Clone ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui
RUN git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale /comfyui/custom_nodes/ComfyUI_UltimateSDUpscale
RUN git clone https://github.com/jags111/efficiency-nodes-comfyui /comfyui/custom_nodes/efficiency-nodes-comfyui
RUN git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes /comfyui/custom_nodes/ComfyUI_Comfyroll_CustomNodes
RUN git clone https://github.com/Fannovel16/comfyui_controlnet_aux /comfyui/custom_nodes/comfyui_controlnet_aux
RUN git clone https://github.com/sipherxyz/comfyui-art-venture /comfyui/custom_nodes/comfyui-art-venture
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts /comfyui/custom_nodes/ComfyUI-Custom-Scripts


# Change working directory to ComfyUI
WORKDIR /comfyui

# Install ComfyUI dependencies
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && pip3 install --no-cache-dir xformers==0.0.21 \
    && pip3 install -r requirements.txt

# Install runpod
RUN pip3 install runpod requests

# Download checkpoints/vae/LoRA to include in image
RUN wget -O models/checkpoints/InteriorDesginV5ForCN.ckpt https://huggingface.co/datasets/Ultimatech/InteriorDesign/blob/main/InteriorDesginV5ForCN.ckpt
RUN wget -O models/checkpoints/InteriorDesginV5ForCN.ckpt https://huggingface.co/datasets/Ultimatech/InteriorDesign/blob/main/InteriorDesginV5ForCN.ckpt
RUN wget -O models/vae/vae-ft-mse-840000-ema-pruned.ckpt https://huggingface.co/stabilityai/sd-vae-ft-mse-original/blob/main/vae-ft-mse-840000-ema-pruned.ckpt
RUN wget -O models/loras/xl_more_art-full_v1.safetensors https://civitai.com/api/download/models/152309
RUN wget -O models/loras/French_Cream_Style_V1.0.safetensors https://huggingface.co/datasets/Ultimatech/InteriorDesign/blob/main/French_Cream_Style%20_V1.0.safetensors
RUN wget -O models/loras/ModerOfficeSD1.5_v1.0.safetensors https://huggingface.co/datasets/Ultimatech/InteriorDesign/blob/main/ModerOfficeSD1.5_v1.0.safetensors

# Download controlnet/IPAdapter to include in image
RUN wget -O models/controlnet/control_v11p_sd15_mlsd.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/blob/main/control_v11p_sd15_mlsd.pth
RUN wget -O models/controlnet/control_v11f1p_sd15_depth.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/blob/main/control_v11f1p_sd15_depth.pth
RUN wget -O models/ipadapter/ip-adapter-plus_sd15.bin https://huggingface.co/h94/IP-Adapter/blob/main/models/ip-adapter-plus_sd15.bin
RUN wget -O models/clip_vision/clip_vision_ipadapter15.safetensors https://huggingface.co/h94/IP-Adapter/blob/main/models/image_encoder/model.safetensors
RUN wget -O models/upscale_models/RealESRGAN_x4.pth https://huggingface.co/ai-forever/Real-ESRGAN/blob/main/RealESRGAN_x4.pth
# Example for adding specific models into image
# ADD models/checkpoints/sd_xl_base_1.0.safetensors models/checkpoints/
# ADD models/vae/sdxl_vae.safetensors models/vae/

# Go back to the root
WORKDIR /

# Add the start and the handler
ADD src/start.sh src/rp_handler.py test_input.json ./
RUN chmod +x /start.sh

# Start the container
CMD /start.sh
