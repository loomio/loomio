#!/bin/bash -e
mkdir -p tmp/pids
if [ "$TASK" = "worker" ];
then
  bundle exec sidekiq
else
  bundle exec puma -C config/puma.rb;
fi
