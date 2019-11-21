ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH=amd64

ARG JACKETT_RELEASE=v0.12.999

ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

RUN apk add --no-cache --virtual .build-dependencies \
        icu-libs \
        libssl1.1 \
        wget \
        tar \
    \
    && apk add --no-cache \
        lua-resty-http=0.13-r0 \
        nginx-mod-http-lua=1.16.1-r1 \
        nginx=1.16.1-r1 \
    \
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
    && apk del --purge .build-dependencies \
    && rm -rf /tmp/* \
             /etc/nginx

 COPY rootfs /
 RUN chmod a+x /run.sh

 CMD [ "/run.sh" ]