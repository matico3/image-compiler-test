# FROM node:18.20.2
FROM node:18.20.2

RUN npm i -g pnpm@7.21.0

# Create a non-root user
RUN useradd -ms /bin/bash appuser
WORKDIR /app

# Install dependencies for Puppeteer
RUN apt-get update && \
    apt-get -y install chromium xvfb gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 \
    libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 \
    libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \
    libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 \
    libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget \
    python3 build-essential openssl libgbm-dev libgtk-3-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 && \
    rm -rf /var/lib/apt/lists/*

# Create font directories and set permissions
RUN mkdir -p /usr/share/fonts/truetype/{DirtyHeadline,TS,HelveticaNeue,GothamBook,Arial} && \
    chown -R appuser:appuser /usr/share/fonts/truetype

# Copy fonts
COPY fonts/Arial/* /usr/share/fonts/truetype/Arial/
COPY fonts/TS/* /usr/share/fonts/truetype/TS/

# Set font permissions
RUN chmod 644 /usr/share/fonts/truetype/Arial/* \
    /usr/share/fonts/truetype/TS/* && \
    chown -R appuser:appuser /usr/share/fonts/truetype

# Update font cache
RUN fc-cache -fv

# Configure font rendering
RUN echo '<?xml version="1.0"?>' > /etc/fonts/local.conf && \
    echo '<!DOCTYPE fontconfig SYSTEM "fonts.dtd">' >> /etc/fonts/local.conf && \
    echo '<fontconfig>' >> /etc/fonts/local.conf && \
    echo '  <match target="font">' >> /etc/fonts/local.conf && \
    echo '    <edit name="antialias" mode="assign"><bool>false</bool></edit>' >> /etc/fonts/local.conf && \
    echo '    <edit name="hinting" mode="assign"><bool>false</bool></edit>' >> /etc/fonts/local.conf && \
    echo '    <edit name="hintstyle" mode="assign"><const>hintnone</const></edit>' >> /etc/fonts/local.conf && \
    echo '    <edit name="rgba" mode="assign"><const>none</const></edit>' >> /etc/fonts/local.conf && \
    echo '    <edit name="lcdfilter" mode="assign"><const>none</const></edit>' >> /etc/fonts/local.conf && \
    echo '  </match>' >> /etc/fonts/local.conf && \
    echo '</fontconfig>' >> /etc/fonts/local.conf

# Install Chrome

# RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
#     && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
#     && apt-get update \
#     && apt-get install -y google-chrome-stable \
#     && rm -rf /var/lib/apt/lists/*
# ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable

# Set Puppeteer specific environment variables
# Install Chrome for Puppeteer as root
# RUN npx puppeteer browsers install chrome
ENV PUPPETEER_PRODUCT=chrome \
    PUPPETEER_SKIP_DOWNLOAD=true \
    # PUPPETEER_ARGS='--no-sandbox --disable-setuid-sandbox' \
    # PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Add these lines to ensure proper permissions and sandbox setup
RUN mkdir -p /home/appuser/.cache/puppeteer && \
    chown -R appuser:appuser /home/appuser/.cache/puppeteer

# Create app directory and set permissions
RUN mkdir -p /app && chown -R appuser:appuser /app

# Switch to non-root user for the remaining operations
USER appuser

# Copy application files
COPY --chown=appuser:appuser package.json pnpm-lock.yaml ./
RUN pnpm install

COPY --chown=appuser:appuser . .

# Command to run the puppeteer script
CMD ["pnpm", "run", "puppeteer"] 
