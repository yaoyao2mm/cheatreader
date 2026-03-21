#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get -o Acquire::Retries=5 update
apt-get -o Acquire::Retries=5 install -y --fix-missing \
  ca-certificates \
  clang \
  cmake \
  curl \
  git \
  libgtk-3-dev \
  liblzma-dev \
  libstdc++-9-dev \
  ninja-build \
  pkg-config \
  unzip \
  xz-utils \
  zip

git clone https://github.com/flutter/flutter.git --depth 1 -b stable /opt/flutter

export PATH="/opt/flutter/bin:${PATH}"

flutter config --enable-linux-desktop
flutter --version
flutter pub get
flutter build linux --release --split-debug-info=build/debug-info/linux
