FROM node:18.20.2

RUN npm i -g pnpm@7.21.0

# Create a non-root user
RUN useradd -ms /bin/bash appuser
WORKDIR /app

# Chromium version linux kaj sem sprobal (je delalo): 132.0.6834.83 with branch base position 1381561 https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html?prefix=Linux_x64/1381561/
# Chromium version na mojem macu: 127.0.6533.88 with branch base position 1313161 https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html?prefix=Mac/1313161/

# Na macu dela, če inštaliraš chromium z apt-get. Inštaliranje specifične verzije heca, ker je x86 architecture

# Install dependencies for Puppeteer
RUN apt-get update && \
    apt-get -y install chromium xvfb gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 \
    libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 \
    libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \
    libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 \
    libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget \
    python3 build-essential openssl libgbm-dev libgtk-3-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 && \
    rm -rf /var/lib/apt/lists/*

# Download and install the specific Chromium snapshot
# RUN wget -q https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/1313161/chrome-linux.zip && \
#   unzip chrome-linux.zip && \
#   mv chrome-linux /usr/local/chromium && \
#   ln -s /usr/local/chromium/chrome /usr/bin/chromium && \
#   rm chrome-linux.zip

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

# Configure font rendering to disable antialiasing
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

# Set Puppeteer specific environment variables
ENV PUPPETEER_PRODUCT=chrome \
    PUPPETEER_SKIP_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Add these lines to ensure proper permissions and sandbox setup
RUN mkdir -p /home/appuser/.cache/puppeteer && \
    chown -R appuser:appuser /home/appuser/.cache/puppeteer

# Create app directory and set permissions
RUN mkdir -p /app && chown -R appuser:appuser /app

# Switch to non-root user for the remaining operations
USER appuser

# Install Puppeteer directly
RUN pnpm add puppeteer@22.15.0

COPY --chown=appuser:appuser . .

# Command to run the puppeteer script
CMD ["pnpm", "run", "puppeteer"] 
