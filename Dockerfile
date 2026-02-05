FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bluez \
        libffi-dev \
        libssl-dev \
        libjpeg-dev \
        zlib1g-dev \
        autoconf \
        build-essential \
        libopenjp2-7 \
        libtiff6 \
        libturbojpeg0-dev \
        tzdata \
        ffmpeg \
        liblapack3 \
        liblapack-dev \
        libatlas-base-dev \
        git \
        libpcap-dev \
        python3 \
        python3-pip \
        python3-venv \
        curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Volta for Node.js management
RUN curl https://get.volta.sh | bash \
    && echo 'export VOLTA_HOME="$HOME/.volta"' >> /home/vscode/.bashrc \
    && echo 'export PATH="$VOLTA_HOME/bin:$PATH"' >> /home/vscode/.bashrc

# Install Node.js LTS using Volta
RUN bash -c "export VOLTA_HOME=/home/vscode/.volta && export PATH=\$VOLTA_HOME/bin:\$PATH && volta install node@lts"

# Install Python packages
RUN pip3 install --no-cache-dir --upgrade wheel pip

# Install Home Assistant
RUN pip3 install --no-cache-dir homeassistant

# Create vscode user if it doesn't exist and setup directories
RUN if ! id -u vscode > /dev/null 2>&1; then \
        useradd -m -s /bin/bash vscode; \
    fi \
    && mkdir -p /config/.storage \
    && chown -R vscode:vscode /config

# Copy container setup script
COPY container /usr/bin/container
COPY hassfest /usr/bin/hassfest
RUN chmod +x /usr/bin/container /usr/bin/hassfest

USER vscode

# Set working directory
WORKDIR /workspaces

ENV HASS_USERNAME=dev
ENV HASS_PASSWORD=dev

CMD ["/usr/bin/container"]