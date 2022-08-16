#!/bin/bash -e
if [ "$TASK" = "worker" ];
then
  bundle exec sidekiq
else
  bundle exec puma -C config/puma.rb;
fi
