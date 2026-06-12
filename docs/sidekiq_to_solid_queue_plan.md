# Replace Sidekiq with Solid Queue

This plan removes Sidekiq as Loomio's background job backend and replaces it with Solid Queue, while explicitly handling existing Sidekiq jobs before cutover.

## Goal

- Replace Sidekiq/Redis-backed job queueing with Solid Queue/PostgreSQL-backed job queueing.
- Execute existing Sidekiq queued and scheduled jobs before removing Sidekiq.
- Keep Loomio runnable without Redis as a hard dependency.

## Current migration approach

- `config.active_job.queue_adapter = :solid_queue`
- Workers inherit from `ApplicationJob`.
- `ApplicationJob` sets `queue_as :default`.
- Runtime enqueue calls use ActiveJob APIs:
  - `perform_later(...)`
  - `set(wait: ...).perform_later(...)`
- `MissionControl::Jobs::Engine` is mounted at `/admin/jobs` behind the existing admin route constraint.
- Solid Queue tables are created in the primary database with a normal Rails migration, not a separate queue database.

## Production cutover

Before deploying the Redis-removal branch, run the drain script while the old bundle still has Sidekiq installed:

```sh
bin/rails runner script/drain_sidekiq_before_job_cutover.rb
```

The script executes every queued and scheduled Sidekiq job, then deletes each job after successful execution. It supports both plain Sidekiq workers and ActiveJob jobs wrapped by Sidekiq.

This project intentionally does not preserve Redis jobs that are enqueued during the deploy window after the drain has run.

## Deployment checklist

1. Run `bin/rails runner script/drain_sidekiq_before_job_cutover.rb` on the old release.
2. Deploy the Solid Queue/Solid Cache/Solid Cable release.
3. Run migrations.
4. Start the worker process with:

   ```sh
   bin/jobs start
   ```

5. Verify `/admin/jobs` loads for admins.
6. Verify representative job flows, including mail delivery and scheduled group deletion.

## Files of interest

- `Gemfile` — removes Sidekiq and adds `solid_queue` / `mission_control-jobs`
- `config/application.rb` — sets Solid Queue as the ActiveJob adapter
- `config/routes.rb` — mounts Mission Control Jobs
- `config/queue.yml` — Solid Queue worker/dispatcher config
- `config/recurring.yml` — recurring Solid Queue tasks
- `bin/jobs` — Solid Queue process entrypoint
- `db/migrate/20260612031248_create_solid_queue_tables.rb` — Solid Queue primary DB tables
- `script/drain_sidekiq_before_job_cutover.rb` — pre-deploy Sidekiq drain script
