#!/bin/bash
set -euxo pipefail
export MAKEFLAGS="-j4"

function cmakebuild() {
  cd $1
  if [[ ! -z "${2:-}" ]]; then
    git checkout $2
  fi
  mkdir build
  cd build
  cmake ${CMAKE_ARGS:-} ..
  make
  make install
  cd ../..
  rm -rf $1
}

cd /tmp

STATIC_PACKAGES="libfftw3-bin libprotobuf17"
BUILD_PACKAGES="git autoconf automake libtool libfftw3-dev pkg-config cmake make gcc g++ libprotobuf-dev protobuf-compiler"
apt-get update
apt-get -y install --no-install-recommends $STATIC_PACKAGES $BUILD_PACKAGES

git clone https://github.com/jketterl/js8py.git
pushd js8py
git checkout 0.1.0
python3 setup.py install
popd
rm -rf js8py

git clone https://github.com/jketterl/csdr.git
cd csdr
git checkout 0.17.0
autoreconf -i
./configure
make
make install
cd ..
rm -rf csdr

git clone https://github.com/jketterl/codecserver.git
mkdir -p /usr/local/etc/codecserver
cp codecserver/conf/codecserver.conf /usr/local/etc/codecserver
# latest develop as of 2021-09-24 (new parsing)
cmakebuild codecserver c51254323b32db5b169cdfc39e043eed6d613a77

git clone https://github.com/jketterl/digiham.git
cmakebuild digiham 0.5.0

apt-get -y purge --autoremove $BUILD_PACKAGES
apt-get clean
rm -rf /var/lib/apt/lists/*
