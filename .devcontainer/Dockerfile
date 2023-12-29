# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.154.0/containers/alpine/.devcontainer/base.Dockerfile

# [Choice] Alpine version: 3.12, 3.11, 3.10, ..., 3.18
ARG VARIANT="3.18"

FROM mcr.microsoft.com/vscode/devcontainers/base:0-alpine-${VARIANT}
# FROM mcr.microsoft.com/devcontainers/dotnet:1-8.0-bookworm
ARG CC65_VERSION="latest"

#RUN apk update && \
#    apk add --no-cache --virtual .build-deps git build-base
    
RUN mkdir -p /sdk
WORKDIR /sdk
RUN git clone https://github.com/cc65/cc65.git
WORKDIR /sdk/cc65
RUN echo 'Using CC65 Version: "${CC65_VERSION}"' 

RUN if [ "${CC65_VERSION}" != "latest" ]; then \
    git checkout tags/${CC65_VERSION} -b "${CC65_VERSION}"; \
    fi
RUN nice make -j2
RUN make install PREFIX=/usr prefix=/usr

WORKDIR /sdk