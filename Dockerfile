FROM ruby:3.0-alpine

RUN apk add \
  build-base \
  postgresql-dev \
  tzdata \
  nodejs \
  yarn
WORKDIR /app
COPY Gemfile* .
RUN bundle install
COPY . .
EXPOSE 3000
RUN bin/rails webpacker:install
RUN bundle exec rake assets:precompile

CMD ["rails", "server", "-b", "0.0.0.0"]
