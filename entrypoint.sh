#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Garante que o banco está ok (cria + migra)
bundle exec rails db:prepare

# Start o servidor
bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}
