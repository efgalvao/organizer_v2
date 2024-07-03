#!/bin/sh

set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Precompile assets if needed
yarn build

# Migrate the database
bundle exec rails db:migrate

bundle exec rake assets:precompile

bundle exec bin/rails server -b 0.0.0.0 -p $PORT
