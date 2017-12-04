#!/bin/bash
if [ "$TASK" = "worker" ];
then
  bundle exec rake jobs:work;
else
  bundle exec rake deploy:build_client
  bundle exec puma -C config/puma.rb;
fi
