ARG ruby_version=3.1.2
ARG base_image=ghcr.io/alphagov/govuk-ruby-base:$ruby_version
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:$ruby_version


FROM $builder_image AS builder

WORKDIR $APP_HOME
COPY Gemfile* .ruby-version ./
RUN bundle install
COPY . .
RUN bootsnap precompile --gemfile .


FROM $base_image


RUN install_packages postgresql-client

# Install `mongodb-database-tools` for 'mongoexport'
# TODO: remove this temporary MongoDB package once we no longer need mongoexport (once the migration to Postgres is done).
ARG mongo_package=mongodb-database-tools-ubuntu2204-x86_64-100.7.2.deb
ARG mongo_package_repo=https://fastdl.mongodb.org/tools/db
WORKDIR /tmp
RUN curl -LSsf "${mongo_package_repo}/${mongo_package}" --output "${mongo_package}" && \
    apt-get install -y --no-install-recommends "./${mongo_package}" && \
    rm -fr /tmp/*

ENV GOVUK_APP_NAME=content-store

WORKDIR $APP_HOME
COPY --from=builder $BUNDLE_PATH $BUNDLE_PATH
COPY --from=builder $BOOTSNAP_CACHE_DIR $BOOTSNAP_CACHE_DIR
COPY --from=builder $APP_HOME .

USER app
CMD ["puma"]
