# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.154.0/containers/alpine/.devcontainer/base.Dockerfile

# [Choice] Alpine version: 3.13, ..., 3.20
ARG VARIANT="3.20"

FROM mcr.microsoft.com/vscode/devcontainers/base:alpine-${VARIANT} as build
ARG CC65_VERSION="latest"

WORKDIR /usr/src
RUN git clone https://github.com/cc65/cc65.git && cd cc65 && \
    if [ "${CC65_VERSION}" != "latest" ]; then \
    git checkout tags/V${CC65_VERSION} -b "tag-${CC65_VERSION}"; \
    fi && \
    nice make -j2 && make install PREFIX=/usr prefix=/usr && \
    rm -rf /usr/src/cc65

WORKDIR /usr
CMD ash