FROM johnday/docker-tools-container

ARG DH=/var/run/docker.sock
ARG DP=.
ARG DTLS=0

ENV DOCKER_HOST $DH
ENV DOCKER_TLS_VERIFY=$DTLS
ENV DOCKER_CERT_PATH=/docker

RUN mkdir /docker

ADD $DP/ /docker/


