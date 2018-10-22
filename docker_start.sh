#!/bin/bash
if [ "$TASK" = "worker" ];
then
  bundle exec rake jobs:work;
else
  if [ ! -d "public/client/`bundle exec rake loomio:version`" ]; then
    bundle exec rake plugins:install client:build
  fi
  bundle exec puma -C config/puma.rb;
fi
