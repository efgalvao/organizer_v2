FROM ruby:3.0-alpine

# Install necessary packages
RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  tzdata \
  nodejs \

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock first to leverage Docker cache
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application code
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# Copy the entrypoint script
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Expose port 3000
EXPOSE 3000

# Set the entrypoint to the script
ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]
