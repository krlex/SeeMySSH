#!/usr/bin/env bash

NAME=$USER

sudo pkg install -y git-lite cmake tmux ttyd

tmux new-session -s "set ssh in browser" -d "ttyd -p 8080 bash -x"
tmux split-window -h -p 50 -t 0 "ssh -R localhost:80:localhost:8080 $NAME@ssh.localhost.run"
tmux a -t "set ssh in browser"
