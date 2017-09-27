#!/bin/bash
if [ "$TASK" = "worker" ];
then
  # build assets
  bundle exec rake assets:precompile;
  bundle exec rake jobs:work;
else
  bundle exec puma -C config/puma.rb;
fi
