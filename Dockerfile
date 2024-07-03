FROM ruby:3.0-alpine

# Install dependencies, including bash and curl
RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  tzdata \
  nodejs \
  npm \
  bash \
  curl

# Install `n` to manage Node.js versions and then use it to install Node.js 20.10.0
RUN npm install -g n && n 20.10.0

# Set the path for the installed Node.js version
ENV PATH /usr/local/n/versions/node/20.10.0/bin:$PATH

# Verify the installed Node.js version
RUN node -v

# Continue with your application setup...
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# Install npm dependencies and run the build
RUN yarn install
RUN yarn build

RUN bundle exec rake assets:precompile

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]
