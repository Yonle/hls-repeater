#!/usr/bin/env bash

set -euo pipefail

source config.sh

RELAYSCRIPTS="$GEN_RELAY_SCRIPTS_DIR"

if ! [ -d "$LIST_STREAMS_DIR" ]; then
    echo "$LIST_STREAMS_DIR directory not found. Ensure that it's exists."
    exit 1
fi

while read categ; do
    RS_C_D="$RELAYSCRIPTS/$categ"
    mkdir -p "$RS_C_D"
    while read ch; do
        ch_f="$ch.sh"
        source "$LIST_STREAMS_DIR/$categ.categ/$ch_f"

        cat << EOF > "$RS_C_D/$ID.sh"
`! [ -z "$CONF"  ] && echo "CONF=$CONF"`
exec $PWD/relay.sh "$categ" "$ID" "$STREAM"       
EOF
        echo "Inserted: $categ | Name: $NAME"

    done < "$LIST_STREAMS_DIR/$categ.categ/LIST"
done < "$LIST_STREAMS_DIR/LIST"

echo "Generated scripts at $RELAYSCRIPTS. Rename to $RELAY_SCRIPTS_DIR to launch"
