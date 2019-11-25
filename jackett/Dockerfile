ARG BUILD_FROM
# hadolint ignore=DL3006
FROM $BUILD_FROM

ARG BUILD_ARCH=amd64

ARG JACKETT_RELEASE

ENV XDG_DATA_HOME="/share/jackett" \
XDG_CONFIG_HOME="/config"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
              libicu60 \
              libssl1.0 \
              # hadolint ignore=DL4001
              wget \
              curl \
              nginx \
              libnginx-mod-http-lua \
              luarocks \
    \
    && luarocks install lua-resty-http 0.13-0 \
    && mkdir -p /opt/Jackett \
    && if [ -z ${JACKETT_RELEASE} ]; then \
              JACKETT_RELEASE=$(curl -sX GET "https://api.github.com/repos/Jackett/Jackett/releases/latest" \
              | jq -r .tag_name); \
        fi \
    && ARCH="${BUILD_ARCH}" \
    && if [ "${BUILD_ARCH}" = "aarch64" ]; then ARCH="ARM64"; fi \
    && if [ "${BUILD_ARCH}" = "amd64" ]; then ARCH="AMDx64"; fi \
    && curl -o \
    /tmp/jackett.tar.gz -L \
    		"https://github.com/Jackett/Jackett/releases/download/${JACKETT_RELEASE}/Jackett.Binaries.Linux${ARCH}.tar.gz" \
    && tar xf \
    /tmp/jackett.tar.gz -C \
    		/opt/Jackett --strip-components=1 \
    && apt-get clean \
    && rm -rf /tmp/* \
              /var/lib/apt/lists/* \
              /var/tmp/* \
              /etc/nginx

 COPY rootfs /
 RUN chmod a+x /run.sh

 CMD [ "/run.sh" ]
