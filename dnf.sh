#!/usr/bin/env bash

NAME=$USER

sudo dnf install -y git cmake.x86_64 make tmux libjson-rpc-cpp-devel.x86_64 libwebsockets-devel.x86_64 json-c-devel.x86_64 openssl-devel.x86_64 zlib-devel.x86_64
git clone https://github.com/tsl0922/ttyd.git

cd ttyd

mkdir build

cd build

cmake ..
sudo make && sudo make install

tmux new-session -s "set ssh in browser" -d "ttyd -p 8080 bash -x"
tmux split-window -h -p 50 -t 0 "ssh -R localhost:80:localhost:8080 $NAME@ssh.localhost.run"
tmux a -t "set ssh in browser"
