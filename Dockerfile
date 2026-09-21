FROM node:24.21.0-alpine3.24

RUN apk add --no-cache icu-data-full && apk upgrade --no-cache

WORKDIR "/app"

COPY package.json package-lock.json ./

RUN npm ci --omit=dev && \
    npm cache clean --force && \
    rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx

COPY bot.js ./

USER node

CMD [ "node", "bot.js" ]
