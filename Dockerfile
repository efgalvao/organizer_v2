FROM ruby:3.0.7-alpine

# Install required packages
RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  tzdata \
  curl \
  git \
  nodejs \
  npm

# Install Yarn
RUN npm install -g yarn

WORKDIR /app

# Gems install (with config to skip dev/test)
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' \
  && bundle install

# Node deps
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy rest of app
COPY . .

# Build frontend
RUN yarn build

# Precompile Rails assets
ENV RAILS_ENV=production
RUN bundle exec rake assets:precompile --trace

# Entrypoint
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]
