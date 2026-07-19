"""Handler serverless de RunPod para LTX-2.3 sobre la imagen antilopax."""
import base64
import glob
import os
import subprocess
import sys
import time

import requests

COMFY = "/app/ComfyUI"
URL = "http://127.0.0.1:8188"


def _link_volume_models() -> None:
    vol = "/runpod-volume/models"
    if not os.path.isdir(vol):
        print("WARN: no existe /runpod-volume/models", flush=True)
        return
    dst = os.path.join(COMFY, "models")
    for sub in os.listdir(vol):
        src_sub = os.path.join(vol, sub)
        if not os.path.isdir(src_sub):
            continue
        dst_sub = os.path.join(dst, sub)
        os.makedirs(dst_sub, exist_ok=True)
        for fname in os.listdir(src_sub):
            link = os.path.join(dst_sub, fname)
            if not os.path.exists(link):
                try:
                    os.symlink(os.path.join(src_sub, fname), link)
                except OSError as e:
                    print(f"WARN symlink {fname}: {e}", flush=True)


def _start_comfy() -> subprocess.Popen:
    return subprocess.Popen(
        [sys.executable, "main.py", "--listen", "127.0.0.1", "--port", "8188"],
        cwd=COMFY,
    )


def _wait_ready(timeout: int = 600) -> bool:
    for _ in range(timeout):
        try:
            if requests.get(f"{URL}/system_stats", timeout=2).ok:
                return True
        except Exception:
            pass
        time.sleep(1)
    return False


_link_volume_models()
_proc = _start_comfy()
if not _wait_ready():
    print("ERROR: ComfyUI no arranco a tiempo", flush=True)

import runpod  # noqa: E402


def handler(job):
    wf = job.get("input", {}).get("workflow")
    if not wf:
        return {"error": "falta 'workflow' en input"}

    r = requests.post(f"{URL}/prompt", json={"prompt": wf})
    if not r.ok:
        return {"error": f"/prompt {r.status_code}: {r.text[:500]}"}
    pid = r.json()["prompt_id"]

    t0 = time.time()
    hist = {}
    for _ in range(900):
        hist = requests.get(f"{URL}/history/{pid}").json()
        entry = hist.get(pid)
        if entry and (entry.get("status", {}).get("completed") or entry.get("outputs")):
            break
        time.sleep(2)

    files = [
        f for f in glob.glob(f"{COMFY}/output/**/*.mp4", recursive=True)
        if os.path.getmtime(f) >= t0 - 5
    ]
    if not files:
        files = glob.glob(f"{COMFY}/output/**/*.mp4", recursive=True)
    if not files:
        return {"error": "no se genero video", "history": hist.get(pid, {})}
    newest = max(files, key=os.path.getmtime)
    with open(newest, "rb") as f:
        return {"video_base64": base64.b64encode(f.read()).decode()}


runpod.serverless.start({"handler": handler})
