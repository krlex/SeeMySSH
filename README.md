# SeeMySSH - Share your SSH terminal over the browser

[![CI](https://github.com/krlex/SeeMySSH/actions/workflows/blank.yml/badge.svg)](https://github.com/krlex/SeeMySSH/actions/workflows/blank.yml)

Share your terminal session over the browser using [ttyd](https://github.com/tsl0922/ttyd), [tmux](https://github.com/tmux/tmux) and an [ssh.localhost.run](https://localhost.run/) tunnel.

## Supported operating systems

- Debian / Ubuntu
- Fedora
- Arch Linux (including Manjaro, EndeavourOS)
- Alpine Linux
- FreeBSD

## Installation

```sh
git clone https://github.com/krlex/SeeMySSH.git
cd SeeMySSH
sh script.sh -u myuser
```

### One-line installation

```sh
bash <(curl -sL https://raw.githubusercontent.com/krlex/SeeMySSH/master/script.sh) -u myuser
```

## Usage

```
Usage: script.sh [OPTIONS]

Options:
  -u, --user USER       Username for ttyd authentication
  -p, --port PORT       Port for ttyd (default: 8080)
  -r, --readonly        Start ttyd in read-only mode
  -U, --uninstall       Kill sessions and remove ttyd
  -h, --help            Show this help message
```

## Examples

Start with the default port (8080) and authentication:

```sh
sh script.sh -u admin
```

Start on a custom port in read-only mode:

```sh
sh script.sh -u viewer -p 9090 --readonly
```

## Uninstall

Kill all active sessions and remove ttyd:

```sh
sh script.sh --uninstall
```

## How it works

1. Detects your OS and installs the required packages (ttyd, tmux, etc.)
2. Builds ttyd from source if it is not already installed (FreeBSD uses packages)
3. Starts a tmux session with ttyd serving a terminal on the configured port
4. Opens an [ssh.localhost.run](https://localhost.run/) tunnel to make the terminal accessible via a public URL

The tunnel provides both SSL and plain HTTP access:

```
https://89e7fc72295ff1.lhr.domains
http://89e7fc72295ff1.lhr.domains
```
