#!/usr/bin/env bash
set -euo pipefail

if command -v nvidia-smi &> /dev/null; then
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n1 | xargs)
    COMPUTE_CAP=$(nvidia-smi --query-gpu=compute_cap --format=csv,noheader | head -n1 | cut -d'.' -f1)
    if [[ "$COMPUTE_CAP" -ge 10 ]] || [[ "$GPU_NAME" == *"5090"* ]] || [[ "$GPU_NAME" == *"5080"* ]] || \
       [[ "$GPU_NAME" == *"B200"* ]] || [[ "$GPU_NAME" == *"B100"* ]] || [[ "$GPU_NAME" == *"GB200"* ]]; then
        VENV_PATH="/app/venv_blackwell"
    else
        VENV_PATH="/app/venv_stable"
    fi
else
    VENV_PATH="/app/venv_stable"
fi

export PATH="$VENV_PATH/bin:$PATH"
export VIRTUAL_ENV="$VENV_PATH"
echo "[worker] GPU=${GPU_NAME:-desconocida} -> venv=$VENV_PATH"
"$VENV_PATH/bin/python3" --version

echo "[worker] instalando runpod + requests en el venv de ComfyUI..."
"$VENV_PATH/bin/python3" -m pip install --no-cache-dir runpod requests

echo "[worker] arrancando handler..."
exec "$VENV_PATH/bin/python3" -u /handler.py
