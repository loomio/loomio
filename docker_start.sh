#!/bin/bash -e
if [ "$TASK" = "worker" ]; then
  bundle exec sidekiq
else
  # bundle install
  bundle exec rake db:prepare
  bundle exec thrust puma -C config/puma.rb
fi
