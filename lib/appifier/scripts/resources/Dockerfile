# Beware: only meant for use with pkg2appimage-with-docker

FROM ubuntu:trusty

ENV TZ=UTC \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    DOCKER_BUILD=1 \
    WORKDIR=/workspace \
    FUNCTIONS_SH=/workspace/functions.sh \
    ARCH=x86_64

RUN set -eux ;\
    # packages ----------------------------------------------------------------
    sed -i 's/archive.ubuntu.com/ftp.fau.de/g' /etc/apt/sources.list ;\
    apt-get update ;\
    apt-get install -y --no-install-recommends \
        imagemagick \
        libxml2-utils \
        apt-transport-https libcurl3-gnutls libarchive13 wget curl \
        desktop-file-utils aria2 fuse gnupg2 build-essential file \
        libglib2.0-bin \
        git jq unzip ;\
    # test user ---------------------------------------------------------------
    useradd --system --no-user-group --uid 1000 test ;\
    # cleanup -----------------------------------------------------------------
    apt-get -y clean autoclean ;\
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* ;\
    # workdir -----------------------------------------------------------------
    install -m 0777 -d "${WORKDIR}"

WORKDIR ${WORKDIR}
