FROM alpine

ARG SING_BOX_NEW=latest CLOUDFLARED_NEW=latest CHMOD=755 CHOWN=1000 NGINX_PORT=8080

COPY --from=ghcr.io/sagernet/sing-box:$SING_BOX_NEW --chmod=$CHMOD --chown=$CHOWN /usr/local/bin/sing-box /usr/local/bin/
COPY --from=cloudflare/cloudflared:$CLOUDFLARED_NEW --chmod=$CHMOD --chown=$CHOWN /usr/local/bin/cloudflared /usr/local/bin/

RUN --mount=type=secret,env=ENTRYPOINT_URL \
  --mount=type=secret,env=NGINX_CONF_URL \
  --mount=type=secret,env=NGINX_40X_HTML_URL <<EOF
  set -euo pipefail
  apk --cache=no upgrade
  apk --cache=no add nginx tini
  wget -qP / "$ENTRYPOINT_URL"
  wget -qP /etc/nginx "$NGINX_CONF_URL"
  wget -qP /var/lib/nginx/html "$NGINX_40X_HTML_URL"
  mkdir -p /app /run/nginx /var/lib/nginx/tmp /var/log/nginx
  chown -R $CHOWN /app /etc/nginx /run/nginx /var/lib/nginx /var/log/nginx
EOF

WORKDIR /app

USER $CHOWN

EXPOSE $NGINX_PORT

HEALTHCHECK CMD wget --spider -q "http://localhost:$NGINX_PORT/health" || exit 1

ENTRYPOINT ["tini", "-g", "--", "/entrypoint.sh"]
