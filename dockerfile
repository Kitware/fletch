# Fletch Dockerfile
# Installs the fletch binary to /opt/kitware/fletch

ARG UBUNTU_VER=18.04
FROM ubuntu:${UBUNTU_VER}

#
# Install System Dependencies
#

RUN apt-get update && apt-get install --no-install-recommends -y \ 
 build-essential \ 
 libgl1-mesa-dev \
 libexpat1-dev \
 libgtk2.0-dev \
 libxt-dev \
 libxml2-dev \
 libssl-dev \
 liblapack-dev \
 openssl \
 curl \
 git \
 python3-dev \
 python3-pip \
 libreadline-dev \
 zlib1g-dev \
 cmake \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && pip3 install numpy

RUN ln -s /usr/bin/python3 /usr/local/bin/python

#
# Build Fletch
#

ENV LD_LIBRARY_PATH=/opt/kitware/fletch/lib/:$LD_LIBRARY_PATH
COPY . /fletch
RUN mkdir -p /fletch/build /opt/kitware/fletch \
  && cd /fletch/build \
  && cmake -DCMAKE_BUILD_TYPE=Release \
    -Dfletch_ENABLE_ALL_PACKAGES=ON \
    -Dfletch_BUILD_WITH_PYTHON=ON \
    -Dfletch_PYTHON_MAJOR_VERSION=3 \
    -Dfletch_BUILD_INSTALL_PREFIX=/opt/kitware/fletch \
    ../ \
  && make -j`nproc` -k \
  && rm -rf /fletch 
