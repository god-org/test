#!/bin/sh

SERVICE_FILE="/app/service.sh"

if [ -z "$SERVICE_URL" ]; then
    exit 1
fi

wget -qO "$SERVICE_FILE" "$SERVICE_URL"

if [ $? -ne 0 ]; then
    exit 1
fi

chmod +x "$SERVICE_FILE"

exec "$SERVICE_FILE"
