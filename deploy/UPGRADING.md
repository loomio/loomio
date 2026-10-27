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

## Contribution tag backfill

The contribution-tag migrations now release schema locks before copying data and build indexes concurrently. Existing opening tags are preserved in small transactions during migration. The full search-tag and thread-summary rebuild runs separately, so it cannot hold up application startup or keep an exclusive schema lock for the duration of the backfill.

After upgrading both web and worker processes, enqueue the backfill:

```sh
docker compose exec app rake loomio:backfill_item_tags
```

Run this only after all processes use the new code: older workers can restore inherited thread tags when reindexing content. Installations that already completed all the original contribution-tag migrations do not need another backfill.

The command returns a job ID. Each low-priority job commits at most 500 records, logs its phase, cursor, captured maximum ID, and update count, then schedules the next batch after one second. Database statements have a one-second timeout and lock waits have a 100-millisecond timeout. Busy or slow batches retry the same cursor; completed batches remain committed. Retrying the job or restarting the pass is safe. Existing opening tags remain visible while tag-filtered search results and cached thread summaries are updated progressively.

Use `BATCH_SIZE` (1–1000) and `STATEMENT_TIMEOUT_MS` to tune the work. Increasing the timeout also increases the possible time a batch holds row locks. To resume manually, set `PHASE` (`summaries` or `search`), `AFTER_ID`, and `THROUGH_ID` to the last completed batch's logged values. The search phase starts automatically after the summary phase finishes. A schema-lock timeout fails the migration promptly instead of leaving new application requests queued behind it; rerun the migration to resume its completed schema steps and rebuild any interrupted concurrent index.

## Finished job cleanup

Restart workers with the updated `config/queue.yml` to restore finished-job cleanup. Custom worker configurations must include `solid_queue_recurring` in the general worker pool. Previously queued cleanup runs will then execute and remove finished jobs older than the retention period (one day by default).

## Email delivery history and incoming email storage

Before pulling the new image, leave the old worker running so queued `RouteReceivedEmailsWorker` and `DeleteOldReceivedEmailsWorker` jobs can finish. From the deployment directory, check how many remain:

```sh
docker compose exec app bin/rails runner \
  'puts SolidQueue::Job.where(class_name: %w[RouteReceivedEmailsWorker DeleteOldReceivedEmailsWorker], finished_at: nil).count'
```

Repeat until the count is zero. If jobs have failed, resolve their errors and retry them through `/admin/jobs`. Pending sender approvals do not need to be cleared. Once the count is zero, stop the old processes:

```sh
docker compose stop app worker
```

Back up the database and Active Storage, then follow the upgrade commands above. Migrations `20261021000002` and `20261021000003` are irreversible, and rebuilding expired incoming email sources can upload data to storage. Upgrade web and job processes together.

Existing bounce/complaint counters become address blocks, and pending sender approvals keep their IDs. Custom approval clients must change `/api/v1/received_emails` to `/api/v1/pending_emails` and the response root from `received_emails` to `pending_emails`.

Incoming-email routing retries failures up to five times with increasing delays. If all retries fail, the job remains failed in `/admin/jobs` for manual review. Jobs already in the failed queue need a manual retry to use the new policy.

## Retained record count repair

After deploying the replacement for `custom_counter_cache`, enqueue a background repair of historical membership, content, read, reply and version counts:

```sh
docker compose exec app rake loomio:repair_record_counts
```

The command prints the job ID and returns after enqueueing. Progress and final results appear in the worker logs with that ID. The bundled `config/queue.yml` serves the `record_count_repair` queue with an additional worker process and one thread, so a long repair does not occupy the general job pool. Restart workers with the new code and queue configuration before enqueueing. Custom queue configurations must serve `record_count_repair` separately from ordinary jobs.

Run this only after all application and worker processes use the new transactional count updates. The schema migration preserves existing counts; the background job repairs historical errors separately while the application and workers remain running. It scans owners in ID order, processes up to 100 owners per transaction, and pauses for 0.1 seconds between batches. It changes count fields only, preserves content and timestamps, and does not rewrite rows whose counts already agree. It takes no table-wide write locks. Writes to the selected owner rows can wait briefly; each repair query has a one-second timeout. A particularly large owner's child records can exceed that timeout even with a batch size of one.

For a background audit that reports drift without changing counts or taking row locks, run:

```sh
docker compose exec -e DRY_RUN=1 app rake loomio:repair_record_counts
```

Worker logs report checked, drifted, updated and deferred rows, plus the last owner ID, elapsed time and longest batch for each table. Busy owners are skipped, and a timed-out batch rolls back before continuing. If records were deferred, the job finishes checking its tables and then fails visibly in Solid Queue. Enqueue another repair of the affected tables from the beginning so skipped records are revisited. Repeating a completed repair is safe. Audits reflect counts at the time each batch is checked; concurrent changes can make their results differ from a later repair.

Use `TABLES` to select any of `groups,users,topics,topic_items,discussions,comments,outcomes`. Set `BATCH_SIZE` (1–1000), `PAUSE_SECONDS`, or `STATEMENT_TIMEOUT_MS` to tune load. These options are saved in the job when it is enqueued. Smaller batches and longer pauses reduce contention. Raising the query timeout also increases how long a batch can hold row locks. For a limited first pass, or to resume an interrupted pass, select one table and supply `LIMIT` or `AFTER_ID`:

```sh
docker compose exec -e TABLES=comments -e LIMIT=1000 app rake loomio:repair_record_counts
docker compose exec -e TABLES=comments -e AFTER_ID=1234 app rake loomio:repair_record_counts
```

Replace `1234` with the last reported ID. Resume this way only when the previous portion had no deferred records; otherwise rerun that table from the beginning. Owners created beyond each table's starting maximum ID are left to the new application's count callbacks.

## Anonymous participation visibility

`LOOMIO_VERIFY_PARTICIPANTS_ADMIN_ONLY` has been removed. After an anonymous poll closes, everyone who can see its results can see who took part. Only group admins see email addresses. Remove the variable from `.env`; it no longer has any effect.

## Group deletion worker configuration

Restart `bin/jobs` processes when deploying the dedicated `group_destruction` queue. The bundled `config/queue.yml` gives that queue one process with one thread; `JOB_CONCURRENCY` scales only the general worker pool. Custom queue configurations must serve `group_destruction` separately and exclude it from general workers. Run only one destruction worker across the deployment if you run multiple job containers. Jobs queued before this change retain their original queue assignment.

Permanent group deletion jobs now require `CLEANUP_ENABLED` to be present when they run and recheck the current `GROUP_DELETION_DELAY_DAYS` against the group's discard timestamp. Apply environment changes by restarting workers. Removing `CLEANUP_ENABLED` stops subsequent jobs from deleting groups; it does not interrupt a deletion already in progress. Skipped jobs finish without deleting and need to be queued again once eligible. Automatic scheduling of discarded-group destruction remains disabled.

## 3.5.0 browser push notifications

New installations receive VAPID keys from `create_env.sh`. For an existing installation, first confirm that `.env` has a valid `SUPPORT_EMAIL` and does not contain any `VAPID_` settings, then run this one line from the deployment directory:

```sh
docker run --rm --env-file .env loomio/loomio:3.5 bundle exec ruby -rweb-push -e 'email = ENV.fetch("SUPPORT_EMAIL"); abort "SUPPORT_EMAIL must be an email address" unless /\A[^\s@]+@[^\s@]+\.[^\s@]+\z/.match?(email); names = %w[VAPID_PUBLIC_KEY VAPID_PRIVATE_KEY VAPID_SUBJECT]; abort "VAPID settings already exist; no changes were made" if names.any? { |name| ENV.key?(name) }; key = WebPush.generate_key; STDOUT.write("\n# Browser push notifications\nVAPID_PUBLIC_KEY=#{key.public_key}\nVAPID_PRIVATE_KEY=#{key.private_key}\nVAPID_SUBJECT=mailto:#{email}\n")' >> .env
```

The command appends one key pair without printing it to the terminal. Keep that pair unchanged across deployments; replacing it invalidates existing browser subscriptions. Then continue with the normal 3.5 update.

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

Loomio 3.3 removes the legacy anonymous stance implementation. Its migration converts any remaining legacy anonymous polls, including discarded polls.

If you are running 3.2, check for open or scheduled legacy anonymous polls that people still need to vote on:

```sh
docker compose run --rm app bundle exec rails runner \
  'puts Poll.kept.where(anonymous: true, voting_system: :stance, closed_at: nil).count'
```

Wait until voting is complete before upgrading. Close those polls through the ordinary Loomio interface if you want them to finish on 3.2; 3.2 queues their conversion when they close. A nonzero count of all legacy anonymous polls does not block the upgrade: 3.3 closes and converts any that remain, including open, scheduled, and discarded polls.

Make and verify a current backup, set `LOOMIO_CONTAINER_TAG=3.3`, and run
`./update.sh`. The 3.3 migration checks the database after conversion and stops with a count and sample poll IDs if any legacy anonymous poll remains.

## Upgrading an older install

The following stepping-stone versions are required when upgrading an older Loomio install. Edit `.env` and change `LOOMIO_CONTAINER_TAG` to each version, then run the upgrade commands above. When the migrations have completed, apply the next tag and repeat.

- v2.4.2
- v2.8.8
- v2.11.13
- v2.15.4
- v2.17.1
- v3.2.0 (complete the anonymous-poll conversion described above)
- v3.3.0 (run its transition migration before upgrading to a later version)
