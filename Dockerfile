FROM docker.io/antilopax/ltx23:v14

RUN pip install --no-cache-dir runpod requests

COPY handler.py /handler.py

CMD ["python", "-u", "/handler.py"]
