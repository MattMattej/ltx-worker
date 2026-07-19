FROM docker.io/antilopax/ltx23:v14

RUN pip install --no-cache-dir runpod requests

COPY handler.py /handler.py

RUN ln -sf "$(command -v python3 || command -v python)" /usr/local/bin/pyrun && \
    /usr/local/bin/pyrun --version

ENTRYPOINT []
CMD ["/usr/local/bin/pyrun", "-u", "/handler.py"]
