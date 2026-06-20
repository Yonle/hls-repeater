#!/usr/bin/env bash

set -euo pipefail

source config.sh

file="$GEN_M3U8_PUBLIC_INDEX.tmp"

make_m3u8_head() {
    cat << EOF > $file
#EXTM3U
#EXTM3U url-tvg="$EPG_URL" tvg-shift=0 m3uautoload=1
EOF
}

put_channel() {
    categ="$1"
    id="$2"
    name="$3"
    stream="$4"
    logo="$5"

    cat << EOF >> $file
#EXTINF:-1 group-title="$categ" tvg-id="$id" tvg-logo="$logo",$name
#KODIPROP:inputstream=inputstream.adaptive
#KODIPROP:inputstreamaddon=inputstream.adaptive
#KODIPROP:inputstream.adaptive.manifest_type=hls
$stream
EOF
}

if ! [ -d "$LIST_STREAMS_DIR" ]; then
    echo "$LIST_STREAMS_DIR directory not found. Ensure that it's exists."
    exit 1
fi

make_m3u8_head

while read categ; do
    while read ch; do
        ch_f="$ch.sh"
        source "$LIST_STREAMS_DIR/$categ.categ/$ch_f"
        put_channel \
            "$categ" \
            "$ID" \
            "$NAME" \
            "$ACCESS_URL/$categ/$ID/index.m3u8" \
            "$LOGO"

        echo "Inserted: $categ | Name: $NAME"

    done < "$LIST_STREAMS_DIR/$categ.categ/LIST"
done < "$LIST_STREAMS_DIR/LIST"

mv -v $file $GEN_M3U8_PUBLIC_INDEX
