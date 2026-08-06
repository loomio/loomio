#!/bin/bash -e

if [ "$TASK" = "worker" ]; then
  exec bin/jobs start
elif [ "$TASK" = "hocuspocus" ]; then
  exec node hocuspocus/server.mjs
else
  # bundle install
  bundle exec rake db:prepare
  exec bundle exec thrust puma -C config/puma.rb
fi
