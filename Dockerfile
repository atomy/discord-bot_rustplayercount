FROM node:18-alpine

# Upgrade Alpine packages, then update npm and patch its bundled picomatch (CVE-2026-33671).
# All done in one RUN layer so Trivy only sees the patched version.
RUN apk add --no-cache icu-data-full && apk upgrade --no-cache && \
    npm install -g npm && \
    npm pack picomatch@4.0.4 --pack-destination /tmp && \
    cd /tmp && tar xzf picomatch-4.0.4.tgz && \
    cp -r /tmp/package/. /usr/local/lib/node_modules/npm/node_modules/picomatch/ && \
    rm -rf /tmp/picomatch-4.0.4.tgz /tmp/package

COPY package.json bot.js /app/

RUN cd /app && npm install

WORKDIR "/app"

CMD [ "node", "bot.js" ]
