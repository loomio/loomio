# Upgrading Loomio

Patch releases within the configured release series do not require changes to `.env`:

```sh
docker compose pull
docker compose up -d
```

Before upgrading to a new minor or major release series, read its notes below and change `LOOMIO_CONTAINER_TAG` in `.env`. Then run:

```sh
docker compose pull
docker compose down
docker compose run --rm app rake db:migrate
docker compose up -d
```

## 3.1.0

Loomio 3.1.0 replaces Sidekiq with Solid Queue. Migrating outstanding Sidekiq jobs is optional, and they are not transferred automatically. Skipping them does not prevent the upgrade or affect primary application data.

To process outstanding jobs before upgrading, download [drain_sidekiq_before_job_cutover.rb](drain_sidekiq_before_job_cutover.rb) into the deployment directory. Stop the application and worker while they are still running the old Sidekiq-enabled image, then run the drain script:

```sh
docker compose stop app worker
docker compose run --rm -v "./drain_sidekiq_before_job_cutover.rb:/tmp/drain_sidekiq_before_job_cutover.rb:ro" app bundle exec rails runner /tmp/drain_sidekiq_before_job_cutover.rb
```

The script executes queued and scheduled jobs, removing each one after it succeeds. Scheduled jobs run immediately, even when their scheduled time has not arrived. Retry and dead jobs are reported but are not executed.

After reviewing the output, change `LOOMIO_CONTAINER_TAG` to `3.1` and run the upgrade commands above. The new `worker` service starts Solid Queue through `bin/jobs start`.

## Upgrading an older install

The following stepping-stone versions are required when upgrading an older Loomio install. Edit `.env` and change `LOOMIO_CONTAINER_TAG` to each version, then run the upgrade commands above. When the migrations have completed, apply the next tag and repeat.

- v2.4.2
- v2.8.8
- v2.11.13
- v2.15.4
- v2.17.1
