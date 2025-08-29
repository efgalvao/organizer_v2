#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

if [ "$RAILS_ENV" = "production" ]; then
  echo "Precompiling assets..."
  bundle exec rake assets:precompile
fi

# Garante que o banco está ok (cria + migra)
bundle exec rails db:prepare

# Start o servidor
bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}
