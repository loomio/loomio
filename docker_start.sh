#!/bin/bash -e
if ! [ -d tmp/pids ]; then
  mkdir -p tmp/pids
fi
if [ "$TASK" = "worker" ]; then
  bundle exec sidekiq
else
  bundle exec puma -C config/puma.rb;
fi