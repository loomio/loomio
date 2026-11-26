#!/bin/bash -e

if [ "$TASK" = "hotcell" ]; then
  export HOME=/tmp
  export BUNDLE_GEMFILE=/loomio/hotcell/Gemfile
  export BUNDLE_PATH=/loomio/hotcell/bundle
  export BUNDLE_WITHOUT=development
  export OMP_NUM_THREADS="${OMP_NUM_THREADS:-2}"
  export OMP_THREAD_LIMIT="${OMP_THREAD_LIMIT:-8}"
  export HOTCELL_CONFIG=/loomio/hotcell/config.rb
  export HOTCELL_OPERATIONS=/loomio/hotcell/operations
  export HOTCELL_DIR="${HOTCELL_DIR:-/run/hotcell/cell}"
  exec bundle exec hotcell
fi

# Merge this release into the persistent Docker Compose volume. New files win,
# while differently named assets from recent releases remain available.
script/sync_client_assets

if [ "$TASK" = "worker" ]; then
  exec bin/jobs start
else
  # bundle install
  bundle exec rake db:prepare
  exec bundle exec thrust puma -C config/puma.rb
fi
