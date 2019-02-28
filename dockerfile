# Fletch Dockerfile

FROM ubuntu:trusty

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

ENV PATH $PATH:/cmake/cmake-3.11.3/bin
RUN mkdir /cmake \
 && cd /cmake \
 && curl -O "https://cmake.org/files/v3.11/cmake-3.11.3.tar.gz" \
 && tar -xvf cmake-3.11.3.tar.gz \
 && rm cmake-3.11.3.tar.gz \
 && cd cmake-3.11.3 \
 && ./configure \
 && make -j8 -k 

#
# Building Fletch
#

ENV LD_LIBRARY_PATH=/fletch_install/lib/:$LD_LIBRARY_PATH

RUN mkdir /fletch_install/ \
  && git clone -b master --single-branch https://github.com/Kitware/fletch.git fletch \ 
  && cd /fletch/ && mkdir build && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release \
    -Dfletch_ENABLE_ALL_PACKAGES=ON \
    -Dfletch_ENABLE_PYTHON=ON \
    -Dfletch_BUILD_INSTALL_PREFIX=/fletch_install \
    ../ \
  && make -j$(nproc) -k \
  && rm -rf /fletch 

CMD [ "bash" ]
