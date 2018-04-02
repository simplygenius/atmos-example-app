FROM ruby:2.5-alpine
MAINTAINER Matt Conway <matt@simplygenius.com>

ENV APP_PORT 4567
ENV APP_DIR /srv/app
ENV BUNDLE_PATH /srv/bundler
ENV BUNDLE_BIN=${BUNDLE_PATH}/bin
ENV GEM_HOME=${BUNDLE_PATH}
ENV PATH="${APP_DIR}:${BUNDLE_BIN}:${PATH}"

RUN mkdir -p $APP_DIR $BUNDLE_PATH
WORKDIR $APP_DIR

COPY Gemfile Gemfile.lock $APP_DIR/

ENV BUILD_PACKAGES="build-base ruby-dev postgresql-dev"
ENV APP_PACKAGES="bash curl postgresql-client"

# The aws-cli package adds an extra 100MB to the image (if not already using
# python), but its the most generic way to get secrets out of s3.  If you need
# to save on image size, you can do the s3 call in a language in common with
# your app so you can save on size.
RUN apk --update upgrade && \
    apk add \
      --virtual app \
      $APP_PACKAGES && \
    apk add \
      --virtual build_deps \
      $BUILD_PACKAGES && \
    apk add aws-cli --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ && \
    bundle install && \
    apk del build_deps && \
    rm -rf /var/cache/apk/*

COPY . $APP_DIR/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD exec bundle exec ruby server.rb -o 0.0.0.0 -p $APP_PORT
