#!/bin/sh

# Exit on any error
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Run any pending migrations
bundle exec rails db:migrate

# Start the Rails server
exec "$@"
