FROM docker.io/antilopax/ltx23:v14

RUN set -eu; \
    PY=""; \
    for c in /opt/conda/bin/python /opt/conda/envs/*/bin/python /venv/bin/python \
             /app/venv/bin/python /app/ComfyUI/venv/bin/python /workspace/venv/bin/python \
             /usr/local/bin/python3 /usr/bin/python3; do \
      if [ -x "$c" ] && "$c" -c "import PIL" >/dev/null 2>&1; then PY="$c"; break; fi; \
    done; \
    [ -n "$PY" ] || { echo "NO python con PIL"; exit 1; }; \
    echo "=== ComfyUI python = $PY ==="; "$PY" --version; \
    "$PY" -m ensurepip --upgrade 2>/dev/null || true; \
    "$PY" -m pip install --no-cache-dir runpod requests; \
    echo "=== verificando ==="; \
    "$PY" -c "import PIL; print('PIL ok')"; \
    "$PY" -c "import requests; print('requests ok')"; \
    "$PY" -c "import runpod; print('runpod ok')"; \
    ln -sf "$PY" /usr/local/bin/pyrun

COPY handler.py /handler.py

ENTRYPOINT []
CMD ["/usr/local/bin/pyrun", "-u", "/handler.py"]
