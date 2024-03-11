#!/usr/bin/env bash

# Use libtcmalloc for better memory management
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"

echo "runpod-worker-comfy: Downloading ComfyUI-Manager"
nodes_dir=/comfyui/custom_nodes

this_node_dir=${nodes_dir}/ComfyUI-Manager
if [[ ! -d $this_node_dir ]]; then
	    git clone https://github.com/ltdrdata/ComfyUI-Manager $this_node_dir
    else
	        (cd $this_node_dir && git pull)
fi
echo "runpod-worker-comfy: Downloaded ComfyUI-Manager"


echo "runpod-worker-comfy: Starting ComfyUI"
python3 /comfyui/main.py --disable-auto-launch --disable-metadata --enable-cors-header "*" --listen 0.0.0.0 --port 8188

#echo "runpod-worker-comfy: Starting RunPod Handler"

# Serve the API and don't shutdown the container
#if [ "$SERVE_API_LOCALLY" == "true" ]; then
   # python3 -u /rp_handler.py --rp_serve_api --rp_api_host=0.0.0.0
#else
    #python3 -u /rp_handler.py
#fi
