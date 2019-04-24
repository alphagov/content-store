FROM ruby:2.6.3
RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y build-essential && apt-get clean
RUN gem install foreman

ENV GOVUK_APP_NAME content-store
ENV GOVUK_CONTENT_SCHEMAS_PATH /govuk-content-schemas
ENV MONGODB_URI mongodb://mongo/content-store
ENV PORT 3068
ENV RAILS_ENV development

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

CMD foreman run web
