# Beware: only meant for use with pkg2appimage-with-docker

FROM ubuntu:trusty

ENV DEBIAN_FRONTEND=noninteractive \
    DOCKER_BUILD=1 \
    WORKDIR=/workspace

RUN set -eux ;\
    # packages ----------------------------------------------------------------
    sed -i 's/archive.ubuntu.com/ftp.fau.de/g' /etc/apt/sources.list ;\
    apt-get update ;\
    apt-get install -y \
        apt-transport-https libcurl3-gnutls libarchive13 wget curl \
        desktop-file-utils aria2 fuse gnupg2 build-essential file libglib2.0-bin \
        git jq ;\
    # test user ---------------------------------------------------------------
    useradd --system --no-user-group --uid 1000 test ;\
    # cleanup -----------------------------------------------------------------
    apt-get clean ;\
    rm -rf /tmp/* /var/tmp/* ;\
    rm -rf /var/lib/apt/lists/* ;\
    # workdir -----------------------------------------------------------------
    install -m 0777 -d "${WORKDIR}"

WORKDIR ${WORKDIR}
