FROM ruby:2.3.0-alpine
MAINTAINER Will Pink <foo@example.com>

# Install packages
RUN apk update && apk add build-base postgresql-client=9.4.9-r0 postgresql-dev

# Install Bundler
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
ENV BUNDLER_VERSION 1.13.6
RUN gem install bundler --version "$BUNDLER_VERSION" --no-rdoc --no-ri

# Create application user
RUN addgroup -g 1000 ticker && adduser -G ticker -D -H -u 1000 ticker

RUN mkdir /ticker
RUN mkdir /gems

COPY api /ticker
WORKDIR /ticker

RUN chown -R ticker /ticker
RUN chown -R ticker /gems

USER ticker

ENV BUNDLE_PATH /gems
RUN bundle install --deployment --path /gems

CMD bundle exec puma -v -b tcp://0.0.0.0:3000

EXPOSE 3000
