FROM ruby:3.0-alpine

# Install dependencies, including bash
RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  tzdata \
  nodejs \
  npm \
  git \
  bash

# Upgrade Node.js to the required version using n
RUN npm install -g n && n 20.10.0

# Ensure the correct Node.js version is used
ENV PATH /usr/local/n/versions/node/20.10.0/bin:$PATH

# Print the Node.js version
RUN node -v

# Install Yarn
RUN npm install -g yarn

# Set the working directory
WORKDIR /app

# Copy Gemfile and install Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Install npm dependencies including devDependencies
RUN yarn install

# Ensure ESBuild runs during asset precompilation
RUN yarn build

# Precompile Rails assets
RUN bundle exec rake assets:precompile

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Expose the application port
EXPOSE 3000

# Set the entrypoint
ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]
