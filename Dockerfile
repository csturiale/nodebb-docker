FROM alpine/git AS clone
ARG nodebb_version=v1.17.0
RUN git clone -b ${nodebb_version} https://github.com/NodeBB/NodeBB.git /tmp/nodebb

FROM node:lts
ARG uid=10005000
ARG gid=10005000
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

COPY demo/plugins/package.json /usr/src/app/package.json

RUN npm install --only=prod && \
    npm cache clean --force

COPY --from=clone /tmp/nodebb/*  /usr/src/app
RUN rm -rf /usr/src/app/demo /usr/src/app/config.json

RUN addgroup --system nodegroup --gid ${gid}

# Create a user 'nodebb' under 'nodegroup'
RUN adduser --system --home /usr/src/app --no-create-home --gid ${gid} --uid ${uid} nodebb

# Chown all the files to the nodebb user.
RUN chown -R nodebb:nodegroup /usr/src/app
USER nodebb

ENV NODE_ENV=production \
    daemon=false \
    silent=false

EXPOSE 4567

VOLUME /usr/src/app/public/uploads

CMD node ./nodebb build ;  node ./nodebb start
