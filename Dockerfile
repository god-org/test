FROM alpine AS builder

ARG TARGETARCH SING_BOX_VERSION CLOUDFLARED_VERSION

RUN set -ex &&
    apk --no-cache upgrade &&
    apk --no-cache add --virtual build-dependencies wget tar ca-certificates &&
    cd /tmp &&
    mkdir -p /local/bin &&
    wget -qO sing-box.tar.gz "https://github.com/SagerNet/sing-box/releases/download/${SING_BOX_VERSION}/sing-box-${SING_BOX_VERSION#v}-linux-${TARGETARCH}.tar.gz" &&
    tar -xzf sing-box.tar.gz &&
    mv sing-box-*/sing-box /local/bin &&
    wget -qO cloudflared "https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-${TARGETARCH}" &&
    mv cloudflared /local/bin &&
    chmod -R +x /local/bin &&
    apk del --purge build-dependencies &&
    rm -rf /tmp/* /var/cache/apk/*

FROM alpine AS dist

COPY entrypoint.sh /entrypoint.sh
COPY --from=builder /local/bin /usr/local/bin

ENTRYPOINT ["/entrypoint.sh"]
