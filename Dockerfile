FROM alpine AS builder
ARG TARGETARCH SING_BOX_NEW CLOUDFLARED_NEW
WORKDIR /tmp
RUN set -ex \
    && wget -qO sing-box.tar.gz "https://github.com/SagerNet/sing-box/releases/download/${SING_BOX_NEW}/sing-box-${SING_BOX_NEW#v}-linux-${TARGETARCH}.tar.gz" \
    && tar -xzf sing-box.tar.gz \
    && mv sing-box-*/sing-box . \
    && wget -qO cloudflared "https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_NEW}/cloudflared-linux-${TARGETARCH}" \
    && chmod +x sing-box cloudflared
FROM alpine AS dist
RUN set -ex \
    && apk --no-cache upgrade \
    && apk --no-cache add tini
WORKDIR /app
COPY entrypoint.sh /entrypoint.sh
COPY --from=builder /tmp/sing-box /tmp/cloudflared /usr/local/bin/
ENTRYPOINT ["tini", "-g", "--", "/entrypoint.sh"]
