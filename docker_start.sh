#!/bin/bash -e
if [ "$TASK" = "worker" ]; then
  bundle exec sidekiq
else
  bundle install
  bundle exec rake db:prepare
  bundle exec puma -C config/puma.rb
fi
