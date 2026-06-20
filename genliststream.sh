#!/usr/bin/env bash

set -euo pipefail

source config.sh

[ -z "$GEN_LISTSTREAMS_DIR" ] && echo "GEN_LISTSTREAMS_DIR NOT FOUND!!" && exit 1

rm -rf "$GEN_LISTSTREAMS_DIR"
mkdir -p "$GEN_LISTSTREAMS_DIR"
touch "$GEN_LISTSTREAMS_DIR/LIST"

PLAYLIST="${1:-playlist.m3u}"

if ! [ -f "$PLAYLIST" ]; then
    echo "Usage: ./genliststream.sh <playlistm3u8_file>"
fi

while IFS= read -r extinf && IFS= read -r stream; do
    extinf=${extinf%$'\r'}
    stream=${stream%$'\r'}

    [[ "$extinf" == \#EXTINF:* ]] || continue

    # Extract fields
    category=$(grep -o 'group-title="[^"]*"' <<<"$extinf" | cut -d'"' -f2)
    epg_id=$(grep -o 'tvg-id="[^"]*"' <<<"$extinf" | cut -d'"' -f2)
    logo=$(grep -o 'tvg-logo="[^"]*"' <<<"$extinf" | cut -d'"' -f2)
    name="${extinf##*,}"

    # Skip entries without an EPG ID
    [[ -n "$epg_id" ]] || continue

    category_dir="$GEN_LISTSTREAMS_DIR/$category.categ"

    mkdir -p "$category_dir"

    cat > "$category_dir/$epg_id.sh" <<EOF
ID="$epg_id"
NAME="$name"
STREAM="$stream"
LOGO="$logo"
EOF

    echo "$epg_id" >> "$category_dir/LIST"

    grep -qxF "$category" "$GEN_LISTSTREAMS_DIR/LIST" || \
      echo "$category" >> "$GEN_LISTSTREAMS_DIR/LIST"

    echo "Created $category_dir/$epg_id.sh"
done < "$PLAYLIST"

echo "Done generating. Please review in $GEN_LISTSTREAMS_DIR/ before applying to $LIST_STREAMS_DIR/"
