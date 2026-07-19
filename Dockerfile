# Worker serverless de LTX-2.3 basado en la imagen que YA funciona (antilopax).
FROM docker.io/antilopax/ltx23:v14

COPY handler.py /handler.py
COPY start.sh /start.sh
RUN chmod +x /start.sh

# La imagen NO tiene un python fijo: su propio /app/startup_unix.sh original elige
# el venv (venv_blackwell o venv_stable) según la GPU detectada en tiempo de
# arranque, por eso ninguna ruta estática funcionaba. start.sh replica esa misma
# detección y lanza el handler con el python correcto (el mismo que usa ComfyUI).
ENTRYPOINT []
CMD ["/start.sh"]
