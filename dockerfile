# Fletch Dockerfile
ARG UBUNTU_VER=18.04
FROM ubuntu:${UBUNTU_VER}

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
 zlib1g-dev \
 python2.7-dev \
 python-pip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && pip install numpy

#
# Building CMake
#
ARG CMAKE_VER=3.14
ARG CMAKE_PATCH=0
ENV PATH $PATH:/cmake/cmake-${CMAKE_VER}.${CMAKE_PATCH}/bin
RUN mkdir /cmake \
 && cd /cmake \
 && curl -O "https://cmake.org/files/v${CMAKE_VER}/cmake-${CMAKE_VER}.${CMAKE_PATCH}.tar.gz" \
 && tar -xvf cmake-${CMAKE_VER}.${CMAKE_PATCH}.tar.gz \
 && rm cmake-${CMAKE_VER}.${CMAKE_PATCH}.tar.gz \
 && cd cmake-${CMAKE_VER}.${CMAKE_PATCH} \
 && ./configure \
 && make -j`nproc` -k 

#
# Building Fletch
#

ENV LD_LIBRARY_PATH=/fletch_install/lib/:$LD_LIBRARY_PATH
COPY . /fletch
RUN mkdir -p /fletch_install/ /fletch/build \
  && cd /fletch/build \
  && cmake -DCMAKE_BUILD_TYPE=Release \
    -Dfletch_ENABLE_ALL_PACKAGES=ON \
    -Dfletch_ENABLE_PYTHON=ON \
    -Dfletch_BUILD_INSTALL_PREFIX=/fletch_install \
    ../ \
  && make -j`nproc` -k \
  && rm -rf /fletch 
