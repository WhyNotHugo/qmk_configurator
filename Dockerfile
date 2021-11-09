# This file uses a multi-stage build strategy. The build stage sets up the nvm environment and builds configurator, while the second stage copies this into a clean container without any build tools.

## First Stage- Build
FROM node:14 as build
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Copy files into place
COPY . /qmk_configurator/
WORKDIR /qmk_configurator/

# Build configurator
RUN yarn install
ENV VUE_APP_API_URL=/api
RUN yarn run build

## Second Stage- Run
FROM nginx as run
EXPOSE 80/tcp
ENV QMK_API_URL="https://api.qmk.fm"

COPY --from=build /qmk_configurator/dist /qmk_configurator/dist
COPY conf/nginx.conf.in /etc/nginx/templates/default.conf.template
COPY bin/docker_run.sh /docker-entrypoint.d/qmk_configurator.sh
