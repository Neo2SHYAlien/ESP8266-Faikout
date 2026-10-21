# Build environment for ESP8266-Faikout (Daikin WiFi controller, ESP8266 port).
#
#   podman build -t faikin-8266-build:v3.4 -f Containerfile .
#   podman run --rm -v "$PWD":/repo -w /repo/ESP faikin-8266-build:v3.4 make
#

FROM docker.io/mbenabda/esp8266-rtos-sdk:v3.4

ENV IDF_PATH=/opt/sdk
ENV PATH=/opt/sdk/tools:/opt/toolchains/lx106/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ARG ESP8266_RTOS_SDK_REPO=https://github.com/Sonic-Amiga/ESP8266_RTOS_SDK.git
ARG ESP8266_RTOS_SDK_REF=Sonic-dev
RUN rm -rf /opt/sdk \
 && git clone -q --branch "${ESP8266_RTOS_SDK_REF}" "${ESP8266_RTOS_SDK_REPO}" /opt/sdk \
 && cd /opt/sdk \
 # components/coap is unused by the port; its nested ext/tinydtls submodule points at
 # git.eclipse.org, which nowadays redirects and aborts `git submodule update --recursive`
 && git config submodule.components/coap/libcoap.update none \
 && git submodule update --init --recursive --depth 1 -q \
 && git log -1 --date=short --pretty='=== ESP8266_RTOS_SDK %h %ad %s'

# --- HOST TOOLS ---------------------------------------------------------------------
# csh         - ESP/ESP Makefile hard-requires /bin/csh (components/ESP32-RevK/buildsuffix)
# libpopt-dev - components/ESP32-RevK/revk_settings generates settings.h
# cmake       - idf.py requires it
RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq csh libpopt-dev cmake tzdata

# --- TIMEZONE -----------------------------------------------------------------------
# Use Europe/Sofia (maintainer local time) so build dates embedded in firmware
# (.desc, version strings) read naturally instead of UTC.
ENV TZ=Europe/Sofia

# --- PYTHON -------------------------------------------------------------------------
# The base image installs the SDK requirements into /root/.local (pip config), which is
# invisible when the container runs as the mapped, non-root user. Install system-wide.
RUN PIP_CONFIG_FILE=/dev/null PIP_TARGET=/usr/local/lib/python3.8/dist-packages \
      python3 -m pip install --no-cache-dir -q -r /opt/sdk/requirements.txt \
 && python3 -c "import click, future, cryptography, pyparsing, elftools; print('=== python deps ok')"

# --- GIT ----------------------------------------------------------------------------
# Under rootless podman the container user does not own /opt/sdk, so git refuses to
# describe it ("unsafe repository").
RUN git config --system --add safe.directory '*'
