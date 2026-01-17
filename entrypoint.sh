#!/bin/sh

if [ -z "$SCRIPT_URL" ]; then
    exit 1
fi

wget -qO run.sh "$SCRIPT_URL"

if [ $? -ne 0 ]; then
    exit 1
fi

chmod +x run.sh

exec run.sh
