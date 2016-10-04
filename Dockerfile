FROM node:4.1.2

ARG APPIUM_VERSION
ARG PATCHED_CHROMEDRIVER="false"

ADD . /root
WORKDIR /root

RUN /root/setup.sh
