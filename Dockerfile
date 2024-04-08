FROM node:11-alpine

COPY . ./schema-registry-ui
# RUN ls
RUN cd schema-registry-ui && npm install && npm run build-prod

FROM alpine

WORKDIR /
# Add needed tools
RUN apk add --no-cache ca-certificates wget \
    && echo "progress = dot:giga" | tee /etc/wgetrc

# Add and Setup Caddy webserver
RUN wget "https://github.com/mholt/caddy/releases/download/v0.10.11/caddy_v0.10.11_linux_amd64.tar.gz" -O /caddy.tgz \
    && mkdir caddy \
    && tar xzf caddy.tgz -C /caddy --no-same-owner \
    && rm -f /caddy.tgz

# Add and Setup Schema-Registry-Ui
COPY --from=0 ./schema-registry-ui/dist/ ./schema-registry-ui
RUN rm -f /schema-registry-ui/env.js \
    && ln -s /tmp/env.js /schema-registry-ui/env.js

# Add configuration and runtime files
ADD Caddyfile /caddy/Caddyfile.template
ADD run.sh /
RUN chmod +x /run.sh

EXPOSE 8000

# USER nobody:nogroup
ENTRYPOINT ["/run.sh"]