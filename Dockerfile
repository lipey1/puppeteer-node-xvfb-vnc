# https://github.com/lipey1/puppeteer-node-xvfb-vnc — base Node + Chrome + Xvfb + VNC (sem CMD)
# + Python/Assinar (PAdES) para assinar PDFs no Vorcel

FROM node:20.9.0

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libxss1 \
    libgtk-3-0 \
    libnss3 \
    libxshmfence1 \
    libxext6 \
    libx11-6 \
    libxtst6 \
    libxrender1 \
    libxcb1 \
    libxfixes3 \
    libxau6 \
    libxdmcp6 \
    libxinerama1 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgbm1 \
    xvfb \
    dbus-x11 \
    fluxbox \
    novnc \
    websockify \
    x11-utils \
    x11-xserver-utils \
    x11vnc \
    # --- Assinar (PAdES / OCR multa) ---
    python3 \
    python3-venv \
    python3-pip \
    tesseract-ocr \
    tesseract-ocr-por \
    libgl1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Venv do Assinar (código/certs vêm no volume ./assinar:/assinar em runtime)
RUN python3 -m venv /opt/assinar-venv \
    && /opt/assinar-venv/bin/pip install -U pip \
    && /opt/assinar-venv/bin/pip install \
        "pymupdf>=1.24.0" \
        "pyHanko[image-support]>=0.35.0" \
    && rm -rf /root/.cache/pip

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
