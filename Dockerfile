ARG base_image=ghcr.io/alphagov/govuk-ruby-base:3.1.2
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:3.1.2

FROM $builder_image AS builder

WORKDIR /app

COPY Gemfile* .ruby-version /app/
RUN bundle install

COPY . /app


FROM $base_image

ENV GOVUK_APP_NAME=content-store

WORKDIR /app

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app /app/

USER app

CMD ["bundle", "exec", "puma"]
