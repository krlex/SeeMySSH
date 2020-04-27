#!/usr/bin/env bash

set -e

NAME=$USER
UNAME=$(uname)


PKG_PACKAGE_NAME="git-lite cmake tmux ttyd"
DEB_PACKAGE_NAME="git cmake make tmux build-essential libjson-c-dev libwebsockets-dev"
DNF_PACKAGE_NAME="git cmake.x86_64 make tmux libjson-rpc-cpp-devel.x86_64 libwebsockets-devel.x86_64 json-c-devel.x86_64 openssl-devel.x86_64 zlib-devel.x86_64"

 if cat /etc/*release | grep ^NAME | grep Fedora; then
    echo "==============================================="
    echo "Installing packages $DNF_PACKAGE_NAME on Fedora"
    echo "==============================================="
    sudo dnf install -y $DNF_PACKAGE_NAME

    git clone https://github.com/tsl0922/ttyd.git

    cd ttyd
    mkdir build
    cd build
    cmake ..
    sudo make && sudo make install
    cd ../../
    rm -rf ttyd/

    tmux new-session -s "set ssh in browser" -d "ttyd -p 8080 bash -x"
    tmux split-window -v
    tmux split-window -h -p 50 -t 0 "ssh -R localhost:80:localhost:8080 $NAME@ssh.localhost.run"
    tmux a -t "set ssh in browser"

 elif cat /etc/*release | grep ^NAME | grep Ubuntu; then
    echo "==============================================="
    echo "Installing packages $DEB_PACKAGE_NAME on Ubuntu"
    echo "==============================================="
    sudo apt-get update
    sudo apt-get install -y $DEB_PACKAGE_NAME

    git clone https://github.com/tsl0922/ttyd.git

    cd ttyd
    mkdir build
    cd build
    cmake ..
    sudo make && sudo make install
    cd ../../
    rm -rf ttyd/

    tmux new-session -s "set ssh in browser" -d "ttyd -p 8080 bash -x"
    tmux split-window -v
    tmux split-window -h -p 50 -t 0 "ssh -R localhost:80:localhost:8080 $NAME@ssh.localhost.run"
    tmux a -t "set ssh in browser"

 elif cat /etc/*release | grep ^NAME | grep Debian; then
    echo "==============================================="
    echo "Installing packages $DEB_PACKAGE_NAME on Debian"
    echo "==============================================="
    sudo apt-get update
    sudo apt-get install -y $DEB_PACKAGE_NAME

    git clone https://github.com/tsl0922/ttyd.git

    cd ttyd
    mkdir build
    cd build
    cmake ..
    sudo make && sudo make install
    cd ../../
    rm -rf ttyd/

    tmux new-session -s "set ssh in browser" -d "ttyd -p 8080 bash -x"
    tmux split-window -h -p 50 -t 0 "ssh -R localhost:80:localhost:8080 $NAME@ssh.localhost.run"
    tmux split-window -v
    tmux a -t "set ssh in browser"

 elif [[ "$OSTYPE" == "freebsd"* ]]; then
    echo "================================================="
    echo "Installing packages $PKG_PACKAGE_NAME on FreeBSD"
    echo "================================================="
    sudo pkg update
    sudo pkg install -y $PKG_PACKAGE_NAME

    tmux new-session -s "set ssh in browser" -d "ttyd -p 8080 bash -x"
    tmux split-window -v
    tmux split-window -h -p 30 -t 0 "ssh -R localhost:80:localhost:8080 $NAME@ssh.localhost.run"
    tmux a -t "set ssh in browser"

 else
    echo "OS NOT DETECTED, couldn't install package $PACKAGE"
    exit 1;
 fi

exit 0
