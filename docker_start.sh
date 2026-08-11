#!/bin/bash -e

# Merge this release into the persistent Docker Compose volume. New files win,
# while differently named assets from recent releases remain available.
script/sync_client_assets

if [ "$TASK" = "worker" ]; then
  exec bin/jobs start
elif [ "$TASK" = "hocuspocus" ]; then
  exec node hocuspocus/server.mjs
else
  # bundle install
  bundle exec rake db:prepare
  exec bundle exec thrust puma -C config/puma.rb
fi
