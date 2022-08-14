FROM ubuntu:18.04 AS stage1
ARG REPO_NAME
WORKDIR /app
COPY ${REPO_NAME}/ .

RUN apt-get update \
    && apt install -y gnupg dpkg-dev apt-utils

RUN gpg --import private-key.asc

COPY build_peervpn/deb/peervpn.deb /app/ubuntu/peervpn.deb

WORKDIR /app/ubuntu

RUN dpkg-scanpackages --multiversion . > Packages \
    && gzip -k -f Packages

RUN apt-ftparchive release . > Release \
    && gpg --default-key "smithy9901@gmail.com" -abs -o - Release > Release.gpg \
    && gpg --default-key "smithy9901@gmail.com" --clearsign -o - Release > InRelease


FROM scratch AS export-stage
COPY --from=stage1 /app/ubuntu ./
