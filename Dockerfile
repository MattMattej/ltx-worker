FROM docker.io/antilopax/ltx23:v14

RUN pip install --no-cache-dir runpod requests

COPY handler.py /handler.py

ENTRYPOINT []
CMD ["bash", "-lc", "python -u /handler.py"]
