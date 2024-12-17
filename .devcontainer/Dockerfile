ARG VARIANT="3.20"

FROM mcr.microsoft.com/devcontainers/base:alpine-${VARIANT} as build

RUN adduser vscode dialout

WORKDIR /usr
CMD ash