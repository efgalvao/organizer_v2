FROM ruby:3.0.7-alpine

# Install required packages and dependencies
RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  tzdata \
  curl \
  git

# Install specific Node.js version and Yarn
RUN apk add --no-cache npm \
  && npm install -g yarn

# Check Node.js version
RUN node -v

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copy the rest of the application code
COPY . .

# Install npm dependencies and run the build
RUN yarn install
RUN yarn build

# Precompile assets
RUN bundle exec rake assets:precompile --trace

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Expose the desired port
EXPOSE 3000

# Define the entrypoint
ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]
