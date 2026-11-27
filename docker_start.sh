#!/bin/bash -e

if [ "$TASK" = "hotcell" ]; then
  # Refuse to boot if app secrets were accidentally passed into the sidecar
  # (e.g. via env_file: ./.env or Kamal's *rails_environment anchor).
  for var in \
    SECRET_KEY_BASE \
    RAILS_MASTER_KEY \
    DATABASE_URL \
    DEVISE_SECRET \
    AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY \
    DO_SECRET_ACCESS_KEY \
    SMTP_PASSWORD \
    CHARGIFY_API_KEY \
    REDIS_CACHE_URL \
    REDIS_QUEUE_URL \
    REDIS_URL \
    VAPID_PRIVATE_KEY \
    GOOGLE_APP_SECRET \
    LOOMIO_CMS_API_TOKEN \
    OPENAI_API_KEY \
    RAILS_INBOUND_EMAIL_PASSWORD \
    TURNSTILE_SECRET_KEY
  do
    if [ -n "${!var:-}" ]; then
      echo "ERROR: Refusing to start TASK=hotcell because $var is set. Remove app secrets / env_file from the hotcell container." >&2
      exit 1
    fi
  done

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
