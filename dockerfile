# Fletch Dockerfile
# Installs the fletch binary to /opt/kitware/fletch

ARG BASE_IMAGE=ubuntu:20.04
ARG ENABLE_CUDA=OFF

FROM ${BASE_IMAGE} AS base

# Install system dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y --no-install-recommends \
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
      wget \
      git \
      libreadline-dev \
      zlib1g-dev \
      python3 \
      python3-dev \
      python3-pip

# Install Qt-specific system dependencies
# See https://doc.qt.io/qt-6/linux-requirements.html
RUN apt-get install -y --no-install-recommends \
      libfontconfig1-dev \
      libfreetype6-dev \
      libx11-dev \
      libx11-xcb-dev \
      libxext-dev \
      libxfixes-dev \
      libxi-dev \
      libxrender-dev \
      libxcb1-dev \
      libxcb-cursor-dev \
      libxcb-glx0-dev \
      libxcb-keysyms1-dev \
      libxcb-image0-dev \
      libxcb-shm0-dev \
      libxcb-icccm4-dev \
      libxcb-sync-dev \
      libxcb-xfixes0-dev \
      libxcb-shape0-dev \
      libxcb-randr0-dev \
      libxcb-render-util0-dev \
      libxcb-util-dev \
      libxcb-xinerama0-dev \
      libxcb-xkb-dev \
      libxkbcommon-dev \
      libxkbcommon-x11-dev

# Install python dependencies
RUN pip3 install numpy cmake
RUN ln -s /usr/bin/python3 /usr/local/bin/python

# Remove unnecessary files
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# Setup build environment
COPY . /fletch
RUN mkdir -p /fletch/build /opt/kitware/fletch
ENV LD_LIBRARY_PATH=/opt/kitware/fletch/lib/:$LD_LIBRARY_PATH

# Configure
RUN cd /fletch/build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -Dfletch_ENABLE_ALL_PACKAGES=ON \
    -Dfletch_BUILD_WITH_PYTHON=ON \
    -Dfletch_BUILD_WITH_CUDA=${ENABLE_CUDA} \
    -Dfletch_PYTHON_MAJOR_VERSION=3 \
    -Dfletch_BUILD_INSTALL_PREFIX=/opt/kitware/fletch \
    -Wno-dev

# Build
RUN cd /fletch/build && \
    make -j$(nproc) -k

# Remove source and temporary build files
RUN rm -rf /fletch

# Remove record of intermediate files
FROM scratch
COPY --from=base / /
