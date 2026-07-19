FROM docker.io/antilopax/ltx23:v14

RUN set -eu; \
    PY=""; \
    for c in /opt/conda/bin/python /opt/conda/envs/*/bin/python /venv/bin/python \
             /app/venv/bin/python /app/ComfyUI/venv/bin/python /workspace/venv/bin/python \
             /usr/local/bin/python3 /usr/bin/python3; do \
      if [ -x "$c" ] && "$c" -c "import PIL" >/dev/null 2>&1; then PY="$c"; break; fi; \
    done; \
    if [ -z "$PY" ]; then echo "NO encontre python con PIL"; exit 1; fi; \
    echo "ComfyUI python = $PY"; \
    "$PY" -m pip install --no-cache-dir runpod requests; \
    ln -sf "$PY" /usr/local/bin/pyrun; \
    /usr/local/bin/pyrun -c "import PIL, runpod, requests; print('deps OK')"

COPY handler.py /handler.py

ENTRYPOINT []
CMD ["/usr/local/bin/pyrun", "-u", "/handler.py"]
