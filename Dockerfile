# docker build --no-cache -t local0state/nordvpn .
# https://github.com/just-containers/s6-overlay/releases/tag/v3.2.0.2
# https://github.com/serversideup/s6-overlay/blob/main/Dockerfile
FROM ubuntu
ENV DEBIAN_FRONTEND="noninteractive" \
    S6_KEEP_ENV=1

ARG S6_OVERLAY_VERSION=3.2.0.2
ARG S6_ARCH=aarch64
ARG URL_PREFIX=https://github.com/just-containers/s6-overlay/releases/download

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends --no-install-suggests curl wireguard s6 ca-certificates apt-transport-https xz-utils && \ 
    curl -sSfL ${URL_PREFIX}/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz -o /tmp/s6-overlay-noarch.tar.xz && \ 
    curl -sSfL ${URL_PREFIX}/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz -o /tmp/s6-overlay-${S6_ARCH}.tar.xz && \ 
    curl -sSfL ${URL_PREFIX}/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz -o /tmp/s6-overlay-symlinks-noarch.tar.xz && \ 
    curl -sSfL ${URL_PREFIX}/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz -o /tmp/s6-overlay-symlinks-arch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-${S6_ARCH}.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz && \
    curl -sSfL https://repo.nordvpn.com/gpg/nordvpn_public.asc -o /etc/apt/trusted.gpg.d/nordvpn_public.asc && \
    echo "deb https://repo.nordvpn.com/deb/nordvpn/debian stable main" > /etc/apt/sources.list.d/nordvpn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nordvpn && \
    apt-get purge -y apt-transport-https xz-utils && \
    apt-get clean && \
    rm -rf \
    /etc/apt/trusted.gpg.d/nordvpn_public.asc \
    /etc/apt/sources.list.d/nordvpn.list \
		/tmp/* \
		/var/cache/apt/archives/* \
		/var/lib/apt/lists/* \
		/var/tmp/* && \
    apt-get update -y

COPY /rootfs /
ENV S6_CMD_WAIT_FOR_SERVICES=1
CMD nord_login && nord_config && nord_connect && nord_migrate && nord_watch
