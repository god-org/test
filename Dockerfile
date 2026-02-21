# syntax=docker/dockerfile:1

ARG SING_BOX_NEW=latest CLOUDFLARED_NEW=latest

FROM ghcr.io/sagernet/sing-box:$SING_BOX_NEW AS sing-box-src
FROM cloudflare/cloudflared:$CLOUDFLARED_NEW AS cloudflared-src
FROM alpine AS alpine-src

RUN \
    --mount=type=secret,id=ENTRYPOINT_URL,env=ENTRYPOINT_URL \
    --mount=type=secret,id=LOCALTIME_URL,env=LOCALTIME_URL \
    --mount=type=secret,id=NGINX_CONF_URL,env=NGINX_CONF_URL \
    --mount=type=secret,id=NGINX_40X_HTML_URL,env=NGINX_40X_HTML_URL <<EOF
set -euo pipefail
wget -qO /entrypoint.sh "$ENTRYPOINT_URL"
wget -qO /localtime "$LOCALTIME_URL"
wget -qO /nginx.conf "$NGINX_CONF_URL"
wget -qO /40x.html "$NGINX_40X_HTML_URL"
EOF

FROM alpine

ARG CHMOD=755 CHOWN=1000 NGINX_PORT=8080

ENV NGINX_PORT=$NGINX_PORT

RUN <<EOF
set -euo pipefail
apk --cache=no upgrade
apk --cache=no add iputils nginx tini
mkdir -p /app /run/nginx /var/lib/nginx/tmp /var/log/nginx
chown -R $CHOWN /app /etc/nginx /run/nginx /var/lib/nginx /var/log/nginx
EOF

COPY --from=sing-box-src --chmod=$CHMOD --link /usr/local/bin/sing-box /usr/local/bin/
COPY --from=cloudflared-src --chmod=$CHMOD --link /usr/local/bin/cloudflared /usr/local/bin/
COPY --from=alpine-src --chmod=$CHMOD --link /entrypoint.sh /
COPY --from=alpine-src --link /localtime /etc/
COPY --from=alpine-src --chown=$CHOWN --link /nginx.conf /etc/nginx/
COPY --from=alpine-src --chown=$CHOWN --link /40x.html /var/lib/nginx/html/

WORKDIR /app

USER $CHOWN

EXPOSE $NGINX_PORT

HEALTHCHECK CMD wget --spider -q "http://localhost:$NGINX_PORT/health" || exit 1

ENTRYPOINT ["tini", "-g", "--", "/entrypoint.sh"]
