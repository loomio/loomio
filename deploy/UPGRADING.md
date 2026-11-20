# Upgrading Loomio

We aim to make Loomio upgrades as maintenance-free as possible. The version notes below cover changes that can require an extra step, such as updating an integration after a breaking change, adding a required secret, or editing a configuration file.

Review the notes for the versions you are upgrading through, set `LOOMIO_CONTAINER_TAG` in `.env`, and run the standard Compose upgrade.

```sh
docker compose pull
docker compose down
docker compose run --rm app rake db:migrate
docker compose up -d
```

You can also run [`update.sh`](update.sh) from the deployment directory to clean up old images and run the upgrade.

```sh
./update.sh
```

## Requiring a live attachment for file downloads

1. Deploy the updated web app and workers with `LOOMIO_REQUIRE_LIVE_BLOB_ATTACHMENT` unset. Confirm that newly emailed HTML, CSV and JSON exports use the `/group_export_downloads/` path and that queued export producers are running the updated code. This starts the waiting period for the site.
2. Wait at least one week. Export links issued before the switch use ordinary attachment URLs and can still be opened during their original lifetime.
3. Purge any CDN or reverse proxy cache entries for `/rails/active_storage/blobs/*` and `/rails/active_storage/representations/*`. Configure those stable paths to respect the app's `Cache-Control: no-store` header. Set `LOOMIO_REQUIRE_LIVE_BLOB_ATTACHMENT=1` in the web app environment and restart or redeploy it.
4. From a fresh signed-out browser session, open a file and its preview using their existing Loomio URLs. Discard the test thread and check that fresh requests to both URLs return 404. Restore the thread and check the same URLs again. Test any previously issued storage URL separately.

A storage URL issued before discard can continue working until its configured expiry. The default is five minutes. Browsers that cached a response under older caching rules may retain their copies, and any file already downloaded can be kept.

## v3.17.0

To upgrade the HTTPS proxy in the bundled Compose deployment to Nginx 1.31.9, use the updated Compose file and set the following in `.env` before pulling images.

```dotenv
LOOMIO_NGINX_PROXY_IMAGE=loomio/nginx-proxy
NGINX_PROXY_CONTAINER_TAG=stable
```

## v3.15.0

### Collaborative editing runs in the app

Since v3.15.0, the app container serves collaborative editing at `/collab_server` on your main hostname. The separate Node.js `hocuspocus` service (container `loomio-hocuspocus`) is no longer needed.

- Update your deployment's `docker-compose.yml` to the [current version](docker-compose.yml), or remove the `hocuspocus` service from your customized Compose file. Changing only the app image tag leaves the old service configured.
- Remove `HOCUSPOCUS_URL` from `.env`.

After upgrading:

- Run `docker compose up -d --remove-orphans` with the updated Compose file to remove the old `loomio-hocuspocus` container. The current `update.sh` already includes this step.
- Remove the `hocuspocus.` DNS record if nothing else uses it.

If a proxy sits in front of the app, it must pass WebSocket upgrades for `/collab_server` as it does for `/cable`.

## v3.14.0

### User and Server API paths

The User API moves to `/api/user0` and the Server API to `/api/server0`. The number increases when a release breaks one of these APIs. `/api/b2` and `/api/b3` still work and will be removed in a later release.

The Server API key is now `SERVER_API_KEY`. `B3_API_KEY` is still read while `SERVER_API_KEY` is unset. Loomio will not start if the key is shorter than 17 characters. To add a key to an existing `.env`:

```sh
echo "SERVER_API_KEY=$(openssl rand -hex 32)" >> .env
```

Poll fields have new names in `/api/user0` requests and responses and in poll CSV exports. `/api/b2` keeps the previous names.

| Previous field | New field |
| --- | --- |
| `voters_count` | `vote_count_eligible` |
| `decided_voters_count` | `vote_count_cast` |
| `undecided_voters_count` | `vote_count_uncast` |
| `cast_stances_pct` | `participation_pct` |
| `stance_counts` | `scores_by_option` |
| `quorum_count` | `quorum_threshold` |
| `quorum_votes_required` | `quorum_shortfall` |
| `min_score` | `score_min` |
| `max_score` | `score_max` |
| `minimum_stance_choices` | `choice_count_min` |
| `maximum_stance_choices` | `choice_count_max` |
| `dots_per_person` | `points_per_voter` |
| `voter_count` (in `results`) | `vote_count` |
| `voter_scores` (in `results`) | `scores_by_voter` |

When updating integrations, use `voters_cast` and `voters_uncast` in place of the audience identifiers `decided_voters` and `undecided_voters`. The closing reminder setting uses `voters_uncast`.

## v3.12.0

If you are upgrading from a version before v3.12.0, drain queued incoming-email jobs before upgrading. [v3.12.0 email migration steps](https://github.com/loomio/loomio/blob/v3.12.0/deploy/UPGRADING.md#email-delivery-history-and-incoming-email-storage)

## v3.11.0

### Retained record count repair

To correct historical counts after upgrading, run `docker compose exec app rake loomio:repair_record_counts`.

The optional repair runs in the background while Loomio is in use. [v3.11.0 count repair instructions](https://github.com/loomio/loomio/blob/v3.11.0/deploy/UPGRADING.md#retained-record-count-repair)

## v3.5.0

### 3.5.0 browser push notifications

New installations receive VAPID keys from `create_env.sh`. For an existing installation, first confirm that `.env` has a valid `SUPPORT_EMAIL` and does not contain any `VAPID_` settings, then run this one line from the deployment directory:

```sh
docker run --rm --env-file .env loomio/loomio:3.5 bundle exec ruby -rweb-push -e 'email = ENV.fetch("SUPPORT_EMAIL"); abort "SUPPORT_EMAIL must be an email address" unless /\A[^\s@]+@[^\s@]+\.[^\s@]+\z/.match?(email); names = %w[VAPID_PUBLIC_KEY VAPID_PRIVATE_KEY VAPID_SUBJECT]; abort "VAPID settings already exist; no changes were made" if names.any? { |name| ENV.key?(name) }; key = WebPush.generate_key; STDOUT.write("\n# Browser push notifications\nVAPID_PUBLIC_KEY=#{key.public_key}\nVAPID_PRIVATE_KEY=#{key.private_key}\nVAPID_SUBJECT=mailto:#{email}\n")' >> .env
```

The command appends one key pair without printing it to the terminal. Keep that pair unchanged across deployments; replacing it invalidates existing browser subscriptions. Then continue with the normal 3.5 update.

## v3.3.0

### Anonymous-voting transition completion

The upgrade closes any remaining legacy anonymous polls and rewrites their votes as ballots stored separately from voter records. It preserves vote choices and aggregate results.

In the new format, each voter can submit one ballot. Once submitted, the vote is final. Voters cannot review, edit, or withdraw it. [Anonymous voting guide](https://www.loomio.com/docs/en/user_manual/polls/anonymous_voting)

## v3.1.0

### Sidekiq to Solid Queue

Loomio 3.1.0 replaces Sidekiq with Solid Queue. Migrating outstanding Sidekiq jobs is optional, and they are not transferred automatically. Skipping them does not prevent the upgrade or affect primary application data.

To process outstanding jobs before upgrading, download [drain_sidekiq_before_job_cutover.rb](drain_sidekiq_before_job_cutover.rb) into the deployment directory. Stop the application and worker while they are still running the old Sidekiq-enabled image, then run the drain script:

```sh
docker compose stop app worker
docker compose run --rm -v "./drain_sidekiq_before_job_cutover.rb:/tmp/drain_sidekiq_before_job_cutover.rb:ro" app bundle exec rails runner /tmp/drain_sidekiq_before_job_cutover.rb
```

The script executes queued and scheduled jobs, removing each one after it succeeds. Scheduled jobs run immediately, even when their scheduled time has not arrived. Retry and dead jobs are reported but are not executed.

After reviewing the output, change `LOOMIO_CONTAINER_TAG` to `3.1` and run the upgrade commands above. The new `worker` service starts Solid Queue through `bin/jobs start`.

---

**Upgrading an older install**

If you are upgrading an older installation, apply the following versions in order, starting with the first one newer than your installed version. For each step, update `LOOMIO_CONTAINER_TAG` in `.env` and run the upgrade commands above before moving to the next version.

- v2.4.2
- v2.8.8
- v2.11.13
- v2.15.4
- v2.17.1
- [v3.3.0](#v330)
