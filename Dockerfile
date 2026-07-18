FROM runpod/worker-comfyui:5.8.6-base

RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/city96/ComfyUI-GGUF && \
    git clone https://github.com/Lightricks/ComfyUI-LTXVideo && \
    pip install -r ComfyUI-GGUF/requirements.txt && \
    pip install -r ComfyUI-LTXVideo/requirements.txt

COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
