FROM ruby:3.0-alpine

# Install Node.js, Yarn, and other dependencies
RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  tzdata \
  nodejs \
  npm \
  git

# Upgrade Node.js to the required version
RUN npm install -g n && n 20.10.0

# Set the working directory
WORKDIR /app

# Copy Gemfile and install Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Install npm dependencies
RUN npm install

# Ensure ESBuild runs during asset precompilation
RUN npm run build

# Precompile Rails assets
RUN bundle exec rake assets:precompile

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Expose the application port
EXPOSE 3000

# Set the entrypoint
ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]
