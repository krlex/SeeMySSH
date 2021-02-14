# SSH in browser over https and http

## Warning

- latest version creates new or rewrights old id_rsa( if you say "y" ) and then starts installation and configuration

- This work on FreeBSD, Debian/Ubuntu, Fedora

- For installation:

  ```
  sudo apt-get install -y git
  git clone https://github.com/krlex/browser-ssh
  ./script.sh
  ```
- If you want to start with authentication, you need to uncomment:
  ```
   ## If want to enable authentication just uncomment this:
   #tmux new-session -s "set ssh in browser" -d "ttyd -p 8080 -c user:password -B bash"
  ```
  and comment:
  ```
  tmux new-session -s "set ssh in browser" -d "ttyd -p 8080 bash -x"
  ```
  and after that start `script.sh`

- If you want to start with some command or something you want do this: ( in exmaple is `tmux a`)

  ```
  tmux new-session -s "set ssh in browser" -d "ttyd -p 8080 -c user:password -B bash -lic 'tmux a'"
  ```
  and this will start in browser with `tmux a`
