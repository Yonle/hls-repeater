#!/usr/bin/env bash

source config.default.sh

if [ -f "config.sh" ]; then
    source config.sh
fi

if [ -n "$CONF" ]; then
    source "$CONF"
fi

SU="${SU:-sudo}"
SIZE="${SIZE:-5G}"

echo "Using ${SU}. Change this by setting SU=<yourpreferredsudoreplacement>"
echo "TMPFS size will be ${SIZE}. Change this by setting SIZE=X where X is an unit. Example: 10G"

if [ "$(findmnt -T "$ROOT_STREAMDIR" -n -o FSTYPE)" = "tmpfs" ]; then
    echo "Already mounted. Remounting... (this won't affect current stream)"

    if ! "$SU" mount \
        -o "remount,size=${SIZE}" \
        "$ROOT_STREAMDIR"
    then
        echo "Please try again."
        exit 1
    fi
else
    if ! "$SU" mount \
        -t tmpfs \
        -o "size=${SIZE},uid=$(id -u),gid=$(id -g),mode=1777" \
        tmpfs "$ROOT_STREAMDIR"
    then
        echo "Please try again."
        exit 1
    fi
fi

echo "Mounted to $ROOT_STREAMDIR. Unmount by running:"
echo "  $SU umount $ROOT_STREAMDIR"
