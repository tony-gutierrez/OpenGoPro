#! /bin/bash
# build.sh/Open GoPro, Version 2.0 (C) Copyright 2021 GoPro, Inc. (http://gopro.com/OpenGoPro).
# This copyright was auto-generated on Tue Feb  8 01:22:35 UTC 2022

cd "$(dirname "$0")"

# Verify Prerequisites
if ! command -v cmake &>/dev/null; then
    echo "cmake can not be found."
    echo "Please install: https://cmake.org/install/"
    exit
fi

CONAN="python -m conans.conan"
version=$($CONAN --version)
if [[ $? != 0 ]]; then # If no version of Conan found
    echo "conan 1.X can not be found."

    if ! command -v python &>/dev/null; then
        echo "Please install: https://docs.conan.io/en/latest/installation.html"
        exit 1
    else
        echo "Trying to install conan with discovered python"
        pip install conan==1.59.0
    fi
fi
version=$($CONAN --version)
version=${version##* }
if [[ ${version%%.*} != 1 ]]; then # If this is Conan >= 2.X
    echo "Found Conan version $version but only 1.X is supported"
    exit 1
fi

# Set up default profile if it does not exist
$CONAN profile new default -- detect >/dev/null 2>&1

set -e

# Install Conan packages
mkdir -p build
cd build
$CONAN install .. --build=missing

# Build binaries with CMake
if [ "$(uname)" == "Darwin" ]; then
    cmake -DCMAKE_BUILD_TYPE=Release ..
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    cmake -DCMAKE_BUILD_TYPE=Release ..
else # Windows. Force to 64 bit.
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_GENERATOR_PLATFORM=x64 ..
fi

cmake --build . --config Release

exit 0
