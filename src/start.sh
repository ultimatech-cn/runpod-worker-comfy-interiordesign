#!/usr/bin/env bash

# Use libtcmalloc for better memory management
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"


#echo "runpod-worker-comfy: Starting RunPod Handler"
 for dir in /workspace/custom_nodes/*/; do \
    if [ -f "$dir/requirements.txt" ]; then \
        pip3 install --no-cache-dir -r "$dir/requirements.txt"; \
    fi; \
done


echo "runpod-worker-comfy: Starting ComfyUI"
python3 /comfyui/main.py --disable-auto-launch --disable-metadata --enable-cors-header "*" --listen 0.0.0.0 --port 8189


# Serve the API and don't shutdown the container
#if [ "$SERVE_API_LOCALLY" == "true" ]; then
   # python3 -u /rp_handler.py --rp_serve_api --rp_api_host=0.0.0.0
#else
    #python3 -u /rp_handler.py
#fi
