#!/usr/bin/env bash
set -euo pipefail

source config.sh

ROOT="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS="$RELAY_SCRIPTS_DIR"
PIDDIR="$ROOT/run"

if ! [ -d "$SCRIPTS" ]; then
    echo "$SCRIPTS is not found"
    exit 1
fi

mkdir -p "$PIDDIR"

start_one() {
    local script="$1"

    local rel="${script#$SCRIPTS/}"
    local name="${rel//\//_}"
    local pidfile="$PIDDIR/$name.pid"

    if [[ -f "$pidfile" ]] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
        echo "[SKIP] $rel already running"
        return
    fi

    bash "$script" \
        >"$ROOT/logs/$name.log" \
        2>&1 &

    pid=$!

    echo $pid > "$pidfile"

    sleep 0.2

    if kill -0 "$pid" 2>/dev/null; then
        echo "[ OK ] Started $rel ($!)"
    else
        echo "[FAIL] Failed to start $rel ($!)"
    fi
}

stop_one() {
    local script="$1"

    local rel="${script#$SCRIPTS/}"
    local name="${rel//\//_}"
    local pidfile="$PIDDIR/$name.pid"

    [[ -f "$pidfile" ]] || return

    pid=$(cat "$pidfile")

    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid"
        echo "[ OK ] Stopped $rel"
    fi

    rm -f "$pidfile"
}

status_one() {
    local script="$1"

    local rel="${script#$SCRIPTS/}"
    local name="${rel//\//_}"
    local pidfile="$PIDDIR/$name.pid"

    if [[ -f "$pidfile" ]] &&
       kill -0 "$(cat "$pidfile")" 2>/dev/null
    then
        echo "[RUN] $rel"
    else
        echo "[---] $rel"
    fi
}

mkdir -p "$ROOT/logs"

mapfile -t scripts < <(find "$SCRIPTS" -type f -name '*.sh' | sort)

case "${1:-}" in
    start)
        for s in "${scripts[@]}"; do
            start_one "$s"
        done
        ;;
    stop)
        for s in "${scripts[@]}"; do
            stop_one "$s"
        done
        ;;
    restart)
        for s in "${scripts[@]}"; do
            stop_one "$s"
        done

        sleep 1

        for s in "${scripts[@]}"; do
            start_one "$s"
        done
        ;;
    status)
        for s in "${scripts[@]}"; do
            status_one "$s"
        done
        ;;
    *)
        echo "Usage:"
        echo "  $0 start"
        echo "  $0 stop"
        echo "  $0 restart"
        echo "  $0 status"
        exit 1
        ;;
esac
