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

# Install `mongodb-database-tools` for 'mongoexport'
RUN wget -P /tmp/ https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu1604-x86_64-100.7.2.deb && \
    apt-get install -y /tmp/mongodb-database-tools-ubuntu1604-x86_64-100.7.2.deb && \
    rm /tmp/mongodb-database-tools-ubuntu1604-x86_64-100.7.2.deb

ENV GOVUK_APP_NAME=content-store

WORKDIR $APP_HOME
COPY --from=builder $BUNDLE_PATH $BUNDLE_PATH
COPY --from=builder $BOOTSNAP_CACHE_DIR $BOOTSNAP_CACHE_DIR
COPY --from=builder $APP_HOME .

USER app
CMD ["puma"]
