#!/bin/sh
set -eu

# ---------------------------------------------------------------------------
# SeeMySSH - Share your SSH terminal over the browser
# Uses ttyd + tmux + ssh.localhost.run tunnel
# ---------------------------------------------------------------------------

# -- Colors & output helpers ------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { printf '%b[INFO]%b  %s\n' "$BLUE" "$NC" "$*"; }
ok()    { printf '%b[OK]%b    %s\n' "$GREEN" "$NC" "$*"; }
warn()  { printf '%b[WARN]%b  %s\n' "$YELLOW" "$NC" "$*" >&2; }
err()   { printf '%b[ERROR]%b %s\n' "$RED" "$NC" "$*" >&2; }
die()   { err "$@"; exit 1; }

# -- Defaults ---------------------------------------------------------------

USER_NAME=""
PASSWORD=""
PORT=8080
READONLY=0
UNINSTALL=0

# -- Usage ------------------------------------------------------------------

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Share your SSH terminal over the browser using ttyd, tmux and ssh.localhost.run.

Options:
  -u, --user USER       Username for ttyd authentication
  -p, --port PORT       Port for ttyd (default: 8080)
  -r, --readonly        Start ttyd in read-only mode
  -U, --uninstall       Kill sessions and remove ttyd
  -h, --help            Show this help message

Examples:
  $(basename "$0") -u admin -p 9090
  $(basename "$0") --readonly --user viewer
  $(basename "$0") --uninstall
EOF
    exit 0
}

# -- Argument parsing -------------------------------------------------------

while [ $# -gt 0 ]; do
    case "$1" in
        -u|--user)
            [ $# -ge 2 ] || die "Option $1 requires an argument"
            USER_NAME="$2"; shift 2 ;;
        -p|--port)
            [ $# -ge 2 ] || die "Option $1 requires an argument"
            PORT="$2"; shift 2 ;;
        -r|--readonly)
            READONLY=1; shift ;;
        -U|--uninstall)
            UNINSTALL=1; shift ;;
        -h|--help)
            usage ;;
        *)
            die "Unknown option: $1 (see --help)" ;;
    esac
done

# -- Input validation -------------------------------------------------------

validate_port() {
    case "$PORT" in
        ''|*[!0-9]*) die "Port must be a number: $PORT" ;;
    esac
    if [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
        die "Port must be between 1 and 65535: $PORT"
    fi
}

prompt_credentials() {
    if [ -z "$USER_NAME" ]; then
        printf "Enter username: "
        read -r USER_NAME
        [ -n "$USER_NAME" ] || die "Username cannot be empty"
    fi

    printf "Enter password: "
    stty -echo 2>/dev/null || true
    read -r PASSWORD
    stty echo 2>/dev/null || true
    printf "\n"
    [ -n "$PASSWORD" ] || die "Password cannot be empty"
}

# -- SSH key ----------------------------------------------------------------

ensure_ssh_key() {
    KEY_FILE="$HOME/.ssh/id_rsa"
    if [ -f "$KEY_FILE" ]; then
        info "SSH key already exists: $KEY_FILE"
    else
        info "Generating SSH key..."
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        ssh-keygen -b 2048 -t rsa -f "$KEY_FILE" -q -N ""
        ok "SSH key generated: $KEY_FILE"
    fi
}

# -- OS detection -----------------------------------------------------------

detect_os() {
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        OS_ID="$ID"
    elif uname | grep -qi freebsd; then
        OS_ID="freebsd"
    else
        die "Cannot detect OS. /etc/os-release not found."
    fi

    case "$OS_ID" in
        alpine|arch|manjaro|endeavouros|fedora|ubuntu|debian|freebsd)
            ok "Detected OS: $OS_ID" ;;
        *)
            die "Unsupported OS: $OS_ID" ;;
    esac
}

# -- Package installation ---------------------------------------------------

install_packages() {
    info "Installing packages for $OS_ID..."

    case "$OS_ID" in
        alpine)
            sudo apk add git musl-dev zlib zlib-dev make libzip libuv-dev \
                json-c-dev cmake tmux gcc libwebsockets-dev libwebsockets
            ;;
        arch|manjaro|endeavouros)
            sudo pacman -S --noconfirm --needed git cmake tmux libwebsockets
            ;;
        fedora)
            sudo dnf install -y git cmake make tmux libjson-rpc-cpp-devel \
                libwebsockets-devel json-c-devel openssl-devel zlib-devel
            ;;
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y git cmake make tmux build-essential \
                libjson-c-dev libwebsockets-dev
            ;;
        freebsd)
            sudo pkg update
            sudo pkg install -y git-lite cmake tmux ttyd
            ;;
    esac

    ok "Packages installed"
}

# -- Build ttyd from source -------------------------------------------------

install_ttyd_from_source() {
    if command -v ttyd >/dev/null 2>&1; then
        ok "ttyd is already installed: $(command -v ttyd)"
        return
    fi

    info "Building ttyd from source..."

    BUILD_DIR=$(mktemp -d)
    trap 'rm -rf "$BUILD_DIR"' EXIT

    git clone https://github.com/tsl0922/ttyd.git "$BUILD_DIR/ttyd"

    mkdir "$BUILD_DIR/ttyd/build"
    cd "$BUILD_DIR/ttyd/build"
    cmake ..
    make
    sudo make install
    cd /

    ok "ttyd installed successfully"
}

# -- Verify dependencies ----------------------------------------------------

verify_deps() {
    for cmd in ttyd tmux ssh; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            die "Required command not found: $cmd"
        fi
    done
    ok "All dependencies verified (ttyd, tmux, ssh)"
}

# -- Start session ----------------------------------------------------------

start_session() {
    TTYD_OPTS="-p $PORT"

    if [ -n "$USER_NAME" ] && [ -n "$PASSWORD" ]; then
        TTYD_OPTS="$TTYD_OPTS -c $USER_NAME:$PASSWORD -B"
    fi

    if [ "$READONLY" -eq 1 ]; then
        TTYD_OPTS="$TTYD_OPTS -R"
    fi

    info "Starting ttyd on port $PORT..."
    info "Credentials: user=$USER_NAME, readonly=$READONLY"

    tmux new-session -s "seemyssh" -d "ttyd $TTYD_OPTS bash -lic 'tmux a'"
    tmux split-window -h -p 50 -t 0 "ssh -R 80:localhost:$PORT ssh.localhost.run"
    tmux split-window -v

    ok "Session created. Attaching..."
    tmux a -t "seemyssh"
}

# -- Uninstall --------------------------------------------------------------

uninstall() {
    info "Uninstalling SeeMySSH..."

    if tmux has-session -t "seemyssh" 2>/dev/null; then
        tmux kill-session -t "seemyssh"
        ok "Killed tmux session: seemyssh"
    else
        warn "No active seemyssh tmux session found"
    fi

    if command -v ttyd >/dev/null 2>&1; then
        TTYD_PATH=$(command -v ttyd)
        sudo rm -f "$TTYD_PATH"
        ok "Removed ttyd: $TTYD_PATH"
    else
        warn "ttyd not found, nothing to remove"
    fi

    ok "Uninstall complete"
    exit 0
}

# -- Main -------------------------------------------------------------------

main() {
    if [ "$UNINSTALL" -eq 1 ]; then
        uninstall
    fi

    validate_port
    prompt_credentials
    ensure_ssh_key
    detect_os
    install_packages

    # FreeBSD gets ttyd from packages; others build from source
    if [ "$OS_ID" != "freebsd" ]; then
        install_ttyd_from_source
    fi

    verify_deps
    start_session
}

main
