# docker build --no-cache -t local0state/nordvpn .

FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends wireguard wget apt-transport-https ca-certificates && \ 
    wget -qO /etc/apt/trusted.gpg.d/nordvpn_public.asc https://repo.nordvpn.com/gpg/nordvpn_public.asc && \
    echo "deb https://repo.nordvpn.com/deb/nordvpn/debian stable main" > /etc/apt/sources.list.d/nordvpn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nordvpn && \
    apt-get clean && \
    rm -rf \
		/tmp/* \
		/var/cache/apt/archives/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

COPY /rootfs /
ENV S6_CMD_WAIT_FOR_SERVICES=1
CMD nord_login && nord_config && nord_connect && nord_migrate && nord_watch
