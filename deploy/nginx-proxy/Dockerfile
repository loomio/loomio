# Keep the existing proxy generator while patching the HTTP server underneath it.
FROM nginxproxy/nginx-proxy:1.11.6-alpine@sha256:99376e95c8754547213d411222a2c4dca046d974e753ae2a1c9aef09b2c03364 AS proxy
FROM nginx:1.31.9-alpine@sha256:90b6bd2aec278b16b98221d64deb1d6d35d164567f507ab0716e6053878315aa

RUN apk add --no-cache bash openssl
COPY --from=proxy /usr/local/bin/docker-gen /usr/local/bin/forego /usr/local/bin/
COPY --from=proxy /etc/nginx/ /etc/nginx/
COPY --from=proxy /usr/share/nginx/html/ /usr/share/nginx/html/
COPY --from=proxy /app/ /app/
ENV NGINX_PROXY_VERSION=1.11.6 \
    DOCKER_GEN_VERSION=0.17.2 \
    DOCKER_HOST=unix:///tmp/docker.sock
WORKDIR /app
ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
