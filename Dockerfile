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






ADD volume/extra_model_paths.yaml ./


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
