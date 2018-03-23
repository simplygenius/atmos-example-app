FROM ruby:2.5-alpine
MAINTAINER Matt Conway <matt@simplygenius.com>

ENV APP_PORT 4567
ENV APP_DIR /srv/app
ENV BUNDLE_PATH /srv/bundler
ENV BUNDLE_BIN=${BUNDLE_PATH}/bin
ENV GEM_HOME=${BUNDLE_PATH}
ENV PATH="${BUNDLE_BIN}:${PATH}"

ENV PACKAGES curl bash

RUN apk update && \
    apk upgrade && \
    apk add $PACKAGES && \
    rm -rf /var/cache/apk/*

RUN mkdir -p $APP_DIR $BUNDLE_PATH
WORKDIR $APP_DIR

COPY Gemfile Gemfile.lock $APP_DIR/
RUN bundle install

COPY . $APP_DIR/

CMD exec bundle exec ruby server.rb -o 0.0.0.0 -p $APP_PORT
