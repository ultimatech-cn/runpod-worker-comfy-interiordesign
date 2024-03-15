# Use Nvidia CUDA base image
FROM yuwenbao/runpod-worker-comfy:base as base


ARG TIMESTAMP=$${TIMESTAMP:-$(date +%Y%m%d%H%M%S)}
ENV TIMESTAMP=${TIMESTAMP}

# Install other necessary dependencies
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
    libglib2.0-0 && apt-get clean -y && rm -rf /var/lib/apt/lists/*


WORKDIR /comfyui


# mkdir folders
RUN mkdir -p models/ipadapter models/upscale_models

# Clone custom_nodes repository
RUN git clone --recurse-submodules   https://github.com/ssitu/ComfyUI_UltimateSDUpscale /comfyui/custom_nodes/ComfyUI_UltimateSDUpscale
RUN git clone https://github.com/jags111/efficiency-nodes-comfyui /comfyui/custom_nodes/efficiency-nodes-comfyui
RUN git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes /comfyui/custom_nodes/ComfyUI_Comfyroll_CustomNodes
RUN git clone https://github.com/Fannovel16/comfyui_controlnet_aux /comfyui/custom_nodes/comfyui_controlnet_aux
RUN git clone https://github.com/sipherxyz/comfyui-art-venture /comfyui/custom_nodes/comfyui-art-venture
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts /comfyui/custom_nodes/ComfyUI-Custom-Scripts
RUN git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus /comfyui/custom_nodes/ComfyUI_IPAdapter_plus






# Download checkpoints/vae/LoRA to include in image
RUN wget -O models/checkpoints/InteriorDesginV5ForCN.ckpt https://huggingface.co/datasets/Ultimatech/InteriorDesign/resolve/main/InteriorDesginV5ForCN.ckpt
RUN wget -O models/checkpoints/laowang_ARCH_MIX_V0.5.safetensors https://huggingface.co/datasets/Ultimatech/InteriorDesign/resolve/main/laowang_ARCH_MIX_V0.5.safetensors
RUN wget -O models/vae/vae-ft-mse-840000-ema-pruned.ckpt https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.ckpt 
RUN wget -O models/loras/French_Cream_Style_V1.0.safetensors https://huggingface.co/datasets/Ultimatech/InteriorDesign/resolve/main/French_Cream_Style%20_V1.0.safetensors
RUN wget -O models/loras/ModerOfficeSD1.5_v1.0.safetensors https://huggingface.co/datasets/Ultimatech/InteriorDesign/resolve/main/ModerOfficeSD1.5_v1.0.safetensors

# Download controlnet/IPAdapter to include in image
RUN wget -O models/controlnet/control_v11p_sd15_mlsd.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_mlsd.pth
RUN wget -O models/controlnet/control_v11f1p_sd15_depth.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1p_sd15_depth.pth
RUN wget -O models/ipadapter/ip-adapter-plus_sd15.bin https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-plus_sd15.bin
RUN wget -O models/clip_vision/clip_vision_ipadapter15.safetensors https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors
RUN wget -O models/upscale_models/RealESRGAN_x4.pth https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x4.pth
# Example for adding specific models into image
# ADD models/checkpoints/sd_xl_base_1.0.safetensors models/checkpoints/
# ADD models/vae/sdxl_vae.safetensors models/vae/
### Check for custom nodes 'requirements.txt' files and then run install
RUN for dir in /comfyui/custom_nodes/*/; do \
    if [ -f "$dir/requirements.txt" ]; then \
        pip3 install --no-cache-dir -r "$dir/requirements.txt"; \
    fi; \
done

#add missing package

RUN pip3 install segment_anything
RUN pip3 install scikit-image
RUN pip3 install omegaconf


# Go back to the root
WORKDIR /

# Add the start and the handler
ADD src/start.sh src/rp_handler.py test_input.json ./
RUN chmod +x /start.sh

# Start the container
CMD /start.sh
