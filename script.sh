#!/bin/sh

check_or_create(){
FILE=~/.ssh/id_dsa
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else
  ssh-keygen -b 2048 -t rsa -f $FILE -q -N ""

fi
}

if [ -z $1 ]; then
  echo "Enter the Username:"
  read USER
else
  USER=$1
fi

stty -echo ; read -p "Enter New Password: " PASSWD; stty echo

echo "Your username $USER and your password only you know"

UNAME=$(uname)

tmux_job(){

    ## If want to enable authentication and readonly just uncomment this:
    tmux new-session -s "set ssh in browser" -d "ttyd -p 8080 -c $USER:$PASSWD -B -R bash -lic 'tmux a'"
    ## and comment default one

    #tmux new-session -s "set ssh in browser" -d "ttyd -p 8080 bash x"
    ## If you want to be 'readonly' just add -R. Example:
    #tmux new-session -s "set ssh in browser" -d "ttyd -p 8080 -R bash x"

    tmux split-window -h -p 50 -t 0 "ssh -R 80:localhost:8080 ssh.localhost.run"
    tmux split-window -v
    tmux a -t "set ssh in browser"

}



PKG_PACKAGE_NAME="git-lite cmake tmux ttyd"
DEB_PACKAGE_NAME="git cmake make tmux build-essential libjson-c-dev libwebsockets-dev"
APK_PACKAGE_NAME="git cmake tmux libwebsockets"
PACMAN_PACKAGE_NAME="git cmake tmux libwebsockets"
DNF_PACKAGE_NAME="git cmake.x86_64 make tmux libjson-rpc-cpp-devel.x86_64 libwebsockets-devel.x86_64 json-c-devel.x86_64 openssl-devel.x86_64 zlib-devel.x86_64"

 if cat /etc/*release | grep ^NAME | grep Alpine; then
   check_or_create
    echo "==============================================="
    echo "Installing packages $APK_PACKAGE_NAME on Alpine"
    echo "==============================================="
    sudo apk add $APK_PACKAGE_NAME

    git clone https://github.com/tsl0922/ttyd.git ~/ttyd

    cd ~/ttyd
    mkdir build
    cd build
    sudo cmake ..
    sudo make && sudo make install
    cd ../../
   tmux_job

 elif cat /etc/*release | grep ^NAME | grep Arch; then
   check_or_create
    echo "==============================================="
    echo "Installing packages $PACMAN_PACKAGE_NAME on Arch"
    echo "==============================================="
    sudo pacman -S -y $PACMAN_PACKAGE_NAME

    git clone https://github.com/tsl0922/ttyd.git ~/ttyd

    cd ~/ttyd
    mkdir build
    cd build
    sudo cmake ..
    sudo make && sudo make install
    cd ../../
   tmux_job

 elif cat /etc/*release | grep ^NAME | grep Fedora; then
   check_or_create
    echo "==============================================="
    echo "Installing packages $DNF_PACKAGE_NAME on Fedora"
    echo "==============================================="
    sudo dnf install -y $DNF_PACKAGE_NAME

    git clone https://github.com/tsl0922/ttyd.git

    cd ttyd
    mkdir build
    cd build
    sudo cmake ..
    sudo make && sudo make install
    cd ../../
    rm -rf ttyd/
   tmux_job


 elif cat /etc/*release | grep ^NAME | grep Ubuntu; then
   check_or_create
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

   tmux_job

 elif cat /etc/*release | grep ^NAME | grep Debian; then
   check_or_create
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
  tmux_job


 elif uname -a | awk '{ print $1}' | grep FreeBSD; then
   check_or_create
    echo "================================================="
    echo "Installing packages $PKG_PACKAGE_NAME on FreeBSD"
    echo "================================================="
    sudo pkg update
    sudo pkg install -y $PKG_PACKAGE_NAME

  tmux_job

 else
    echo "OS NOT DETECTED, couldn't install package $PACKAGE"
    exit 1;
 fi

exit 0
