#!/bin/bash -e

# Copy built assets into the persistent volume (preserving old assets)
mkdir -p /loomio/public/client3
cp -r /loomio/client3-build/* /loomio/public/client3/

# Remove asset files older than 90 days
find /loomio/public/client3 -type f -mtime +90 -delete

if [ "$TASK" = "worker" ]; then
  bundle exec sidekiq
elif [ "$TASK" = "hocuspocus" ]; then
  node hocuspocus/server.mjs
else
  # bundle install
  bundle exec rake db:prepare
  bundle exec thrust puma -C config/puma.rb
fi
