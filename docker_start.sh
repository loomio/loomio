#!/bin/bash -e
if [ "$TASK" = "worker" ];
then
  bundle exec sidekiq
else
  if [ ! -d "public/client/`bundle exec rake loomio:version`" ]; then
    bundle exec rake plugins:install client:build
  fi
  bundle exec puma -C config/puma.rb;
fi
