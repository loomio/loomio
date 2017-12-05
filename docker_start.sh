#!/bin/bash
if [ "$TASK" = "worker" ];
then
  bundle exec rake jobs:work;
else
  bundle exec rake plugins:fetch[plugins.docker] plugins:install deploy:build
  bundle exec puma -C config/puma.rb;
fi
