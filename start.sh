#!/bin/bash
set -euo pipefail

export DISPLAY="${DISPLAY:-:99}"
SCREEN="${SCREEN_WIDTH:-1280}x${SCREEN_HEIGHT:-720}x${SCREEN_DEPTH:-24}"
VNC_PASSWORD="${VNC_PASSWORD:-123}"

rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 2>/dev/null || true
Xvfb "${DISPLAY}" -screen 0 "${SCREEN}" &
for _ in $(seq 1 50); do
  xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1 && break
  sleep 0.1
done

mkdir -p ~/.vnc
x11vnc -storepasswd "${VNC_PASSWORD}" ~/.vnc/passwd

fluxbox &
sleep 0.5

if [[ -d /usr/share/novnc ]]; then
  websockify --web /usr/share/novnc 6080 localhost:5900 &
fi

x11vnc -display "${DISPLAY}" -forever -shared -rfbauth ~/.vnc/passwd -rfbport 5900 -noxdamage &
sleep 0.5

mkdir -p /tmp/vorcel-origin /tmp/vorcel-destiny
chmod 1777 /tmp/vorcel-origin /tmp/vorcel-destiny

cd /app
for profile_root in /app/data-origin /app/data-destiny; do
  if [[ -d "${profile_root}" ]]; then
    find "${profile_root}" -maxdepth 4 \( -name SingletonLock -o -name SingletonSocket -o -name SingletonCookie \) -type f -delete 2>/dev/null || true
  fi
done

exec node app.js
