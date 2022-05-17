# (unless we decide to use Bitnami instead)
ARG base_image=ruby:3.0.4-slim-buster

FROM $base_image AS builder
ENV RAILS_ENV=production
# TODO: have a separate build image which already contains the build-only deps.
RUN apt-get update -qy && \
    apt-get upgrade -y && \
    apt-get install -y build-essential
RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle config set without 'development test' && \
    bundle install -j8 --retry=2
COPY . ./

FROM $base_image
ENV GOVUK_PROMETHEUS_EXPORTER=true RAILS_ENV=production GOVUK_APP_NAME=content-store
# TODO: apt-get upgrade in the base image
RUN apt-get update -qy && \
    apt-get upgrade -y
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app /app/
WORKDIR /app
CMD bundle exec puma
