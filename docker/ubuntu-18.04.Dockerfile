FROM ubuntu:bionic-20200713@sha256:767eea1efb29ab7e215e1d97c8d758df5d587ca86e769a2dfb254c6b022895c3

LABEL maintainer="Jeroen de Bruijn <vidavidorra@gmail.com>"
ARG DEBIAN_FRONTEND=noninteractive

# Install generic packages.
#
# The apt-utils package is to workaround to what seems to be an Ubuntu bug. See
# https://github.com/tianon/docker-brew-ubuntu-core/issues/59 for more details.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  apt-utils \
  ca-certificates \
  uuid-runtime \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install and configure locales.
RUN apt-get update \
  && apt-get install -y --no-install-recommends locales \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -c -f UTF-8 \
  -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Additional packages from sources.
COPY ./src /usr/docker-linux/src
ENV PATH /home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}
RUN /usr/docker-linux/src/install_homebrew.sh

# Clean up.
#
# Delete all the apt list files since they're big and get stale quickly. This
# forces "apt-get update" in dependent images, which is also good. See also
# https://bugs.launchpad.net/cloud-images/+bug/1699913.
RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/*
