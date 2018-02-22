#!/bin/bash

# Install dependencies (debbootstrap)
sudo apt-get install -yqq debootstrap curl

# -----------------------------------------------------------------------------
# BUILD/LABEL VARIABLES
# -----------------------------------------------------------------------------
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION="latest"
VCS_URL=$(git config --get remote.origin.url)
VCS_REF=$(git rev-parse --short HEAD)

# Fetch the latest Kali debootstrap script from git
curl "http://git.kali.org/gitweb/?p=packages/debootstrap.git;a=blob_plain;f=scripts/kali;h=50d7ef5b4e9e905cc6da8655416cdf3ef559911e;hb=refs/heads/kali/master" > kali-debootstrap &&\
sudo debootstrap kali-rolling ./kali-root http://repo.kali.org/kali ./kali-debootstrap &&\
sudo tar -C kali-root -c . | sudo docker import - kalilinux/kali-linux-docker &&\
sudo rm -rf ./kali-root &&\
TAG=$(sudo docker run -t -i kalilinux/kali-linux-docker awk '{print $NF}' /etc/debian_version | sed 's/\r$//' ) &&\
echo "Tagging kali with $TAG" &&\
sudo docker tag kalilinux/kali-linux-docker:$VERSION kalilinux/kali-linux-docker:$TAG &&\
echo "Labeling kali" &&\
sudo docker build --squash --rm -t kalilinux/kali-linux-docker:$VERSION \
--build-arg BUILD_DATE=$BUILD_DATE \
--build-arg VERSION=$VERSION \
--build-arg VCS_URL=$VCS_URL \
--build-arg VCS_REF=$VCS_REF . &&\
echo "Build OK" || echo "Build failed!"
