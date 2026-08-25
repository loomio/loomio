FROM node:25-alpine

WORKDIR /opt/haraka

COPY package.json package-lock.json ./

COPY haraka /haraka

RUN apk update
RUN apk upgrade
RUN apk add --no-cache ca-certificates
RUN update-ca-certificates
RUN apk add --no-cache --virtual .build-deps python3 g++ make openssl
RUN npm ci --omit=dev
RUN openssl dhparam -out /haraka/config/dhparams.pem 2048
RUN chmod +x /haraka/docker-entrypoint.sh
RUN apk del .build-deps && rm -rf /var/cache/apk/* /root/.npm/* /tmp/*

ENV HARAKA_HOME=/haraka

EXPOSE 25 587

ENTRYPOINT ["/haraka/docker-entrypoint.sh"]

CMD ["-c", "/haraka"]
