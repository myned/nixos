# https://caddyserver.com/docs/build#docker
# https://hub.docker.com/_/caddy/tags
FROM caddy:2-builder AS builder

RUN xcaddy build \
  --with github.com/caddy-dns/cloudflare \
  --with github.com/mholt/caddy-l4
# --with github.com/tailscale/caddy-tailscale

FROM caddy:2

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
