# Upgrading Loomio

Before upgrading to a new minor or major release series, read its notes below and change `LOOMIO_CONTAINER_TAG` in `.env`. Then run:

```sh
docker compose pull
docker compose down
docker compose run --rm app rake db:migrate
docker compose up -d
```

Or run [`update.sh`](update.sh) from the deployment directory, which performs these steps for you (image cleanup, pull, migrate, restart):

```sh
./update.sh
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

## 3.2.0 anonymous-voting transition

Loomio 3.2.0 introduces detached anonymous voting. Existing legacy anonymous
polls continue normally while open. Closed polls are converted by delayed
background jobs; a poll that closes later queues its own conversion.

Allow the anonymous-poll conversion jobs to finish before upgrading beyond
3.2. The next release's notes will describe that upgrade.

## 3.3.0 anonymous-voting transition completion

Loomio 3.3 removes the legacy anonymous stance implementation. Existing
installations must run 3.2 first and complete every anonymous-poll conversion.

While still running the 3.2 image, check the remaining count:

```sh
docker compose run --rm app bundle exec rails runner \
  'puts Poll.where(anonymous: true, voting_system: :stance).count'
```

Do not continue until the command prints `0`. Open and scheduled legacy polls
must be closed through the ordinary Loomio interface when voting is complete;
3.2 queues their conversion when they close.

Make and verify a current backup, set `LOOMIO_CONTAINER_TAG=3.3`, and run
`./update.sh`. The 3.3 migration checks the database again and stops with a
count and sample poll IDs if any legacy anonymous poll remains.

## Upgrading an older install

The following stepping-stone versions are required when upgrading an older Loomio install. Edit `.env` and change `LOOMIO_CONTAINER_TAG` to each version, then run the upgrade commands above. When the migrations have completed, apply the next tag and repeat.

- v2.4.2
- v2.8.8
- v2.11.13
- v2.15.4
- v2.17.1
