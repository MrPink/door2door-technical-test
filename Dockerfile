FROM ruby:2.3.0-alpine
MAINTAINER Will Pink <foo@example.com>

# Install packages
RUN apk update && apk add build-base postgresql-client=9.4.9-r0 postgresql-dev

# Install Bundler
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
ENV BUNDLER_VERSION 1.13.6
RUN gem install bundler --version "$BUNDLER_VERSION" --no-rdoc --no-ri

# Create application user
RUN addgroup -g 1000 ticks && adduser -G ticks -D -H -u 1000 ticks

RUN mkdir /ticks
RUN mkdir /gems

COPY api /ticks
WORKDIR /ticks

RUN chown -R ticks /ticks
RUN chown -R ticks /gems

USER ticks

ENV BUNDLE_PATH /gems
RUN bundle install --deployment --path /gems

CMD bundle exec puma -v -b tcp://0.0.0.0:3000

EXPOSE 3000
