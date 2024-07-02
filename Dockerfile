FROM ruby:3.0-alpine

RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  tzdata \
  nodejs \
  yarn \
  git

WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock first to leverage Docker cache
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Remove package-lock.json to avoid conflicts with Yarn
RUN rm -f package-lock.json

# Copy the rest of the application code
COPY . .

# Create a symbolic link for application.scss
RUN mkdir -p app/javascript/stylesheets && ln -s ../../../assets/stylesheets/application.scss app/javascript/stylesheets/application.scss

# Install yarn dependencies
RUN yarn install

# Add this line before the build step in Dockerfile
RUN ls -lR /app

# Build assets
RUN yarn build

# Precompile assets (for production)
RUN bundle exec rails assets:precompile

# Copy the entrypoint script
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Expose port 3000
EXPOSE 3000

# Set the entrypoint to the script
ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]
