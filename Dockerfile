FROM ruby:3.0-alpine

# Install necessary packages
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    nodejs \
    yarn \
    git \
    curl

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | sh - \
    && apk add --no-cache nodejs

WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application code
COPY . .

# Install npm dependencies and run the build
RUN yarn install
RUN node esbuild.config.js

# Precompile assets
RUN bundle exec rake assets:precompile

# Copy entrypoint script and set permissions
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Expose port and set entrypoint
EXPOSE 3000
ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]
