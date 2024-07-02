FROM ruby:3.0-alpine

RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  tzdata \
  nodejs \
  yarn

WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock first to leverage Docker cache
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application code
COPY . .

# Precompile assets (for production)
RUN bundle exec rails assets:precompile

# Copy the entrypoint script
COPY entrypoint.sh /usr/bin/

# Make the entrypoint script executable
RUN chmod +x /usr/bin/entrypoint.sh

# Expose port 3000
EXPOSE 3000

# Set the entrypoint to the script
ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]
