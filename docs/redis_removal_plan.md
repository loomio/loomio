# Remove Redis from Loomio

This plan records the agreed direction for removing Loomio's remaining Redis dependencies after replacing Sidekiq with Solid Queue.

## Target architecture

Use PostgreSQL/Rails-backed components instead of Redis:

| Concern | Current | Target |
| --- | --- | --- |
| Background jobs | Sidekiq + Redis | Solid Queue + PostgreSQL |
| Rails cache | Redis cache store | Solid Cache by default |
| Action Cable | Redis adapter | Solid Cable |
| Demo group ID queue | `redis-objects` list | `Rails.cache` array backed by Solid Cache |
| Throttling | `redis-objects` counters | `Rails.cache` counters backed by Solid Cache |
| Redis object setup | `CACHE_REDIS_POOL`, `Redis::Objects.redis` | removed |
| Gems | `redis-objects`, Redis pulled transitively | removed once Sidekiq is also gone |
| CI Redis service | Redis service containers | removed after all app uses are gone |

## Dependencies to add/remove

Add gems if they are not already present:

```rb
gem "solid_queue"
gem "mission_control-jobs"
gem "solid_cache"
gem "solid_cable"
```

Solid Queue migration is tracked separately in `docs/sidekiq_to_solid_queue_plan.md`.

Remove once no code references Redis or `redis-objects`:

```rb
gem "redis-objects"
gem "connection_pool", "~> 2.4" # only if no longer needed by another direct dependency
```

`redis` and `redis-client` should disappear from `Gemfile.lock` once Sidekiq and `redis-objects` are removed, unless another dependency still pulls them in. Loomio should not keep Redis as a hard dependency or provide app-specific Redis fallbacks for jobs, cable, demo queues, or throttles.

## Solid Cache

Replace Redis cache configuration in:

- `config/application.rb`
- `config/environments/test.rb`

Current production-ish default:

```rb
config.cache_store = :redis_cache_store, { url: (ENV['REDIS_CACHE_URL'] || ENV.fetch('REDIS_URL', 'redis://localhost:6379')) }
```

Target default:

```rb
config.cache_store = :solid_cache_store
```

Run the Solid Cache installer/migrations according to the installed gem version.

Do not keep Redis-specific Loomio fallback configuration. Redis can still be used only in the normal Rails sense: an operator may override `config.cache_store` to any Rails-supported backend in their own deployment configuration. Loomio's checked-in default should be Solid Cache and tests should not require Redis.

## Solid Cable

Replace Redis Action Cable configuration in `config/cable.yml`. Do not keep a Redis Action Cable fallback in checked-in Loomio configuration.

Current:

```yml
development:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL", "redis://localhost:6379/0") %>

test:
  adapter: test

production:
  adapter: redis
  url: <%= ENV.fetch("REDIS_QUEUE_URL", ENV.fetch("REDIS_URL", "redis://localhost:6379/0")) %>
```

Target shape:

```yml
development:
  adapter: solid_cable

test:
  adapter: test

production:
  adapter: solid_cable
```

Run the Solid Cable installer/migrations according to the installed gem version.

## DemoService

`DemoService` currently uses Redis only as a transient list of group IDs:

```rb
Redis::List.new('demo_group_ids').value
Redis::List.new('demo_group_ids').push(group.id)
Redis::List.new('demo_group_ids').shift
Redis::List.new('demo_group_ids').clear
Redis::List.new('demo_group_ids').unshift(*existing_ids)
```

Because the list stores IDs only, and the underlying records are real `Group` records, this fits well in `Rails.cache` once Solid Cache backs the cache store.

Suggested implementation:

```rb
class DemoService
  DEMO_GROUP_IDS_CACHE_KEY = "demo_group_ids"
  DEMO_QUEUE_LOCK_KEY = 123456789

  def self.demo_group_ids
    Rails.cache.fetch(DEMO_GROUP_IDS_CACHE_KEY) { [] }
  end

  def self.write_demo_group_ids(ids)
    Rails.cache.write(DEMO_GROUP_IDS_CACHE_KEY, ids)
  end

  def self.with_demo_queue_lock
    ActiveRecord::Base.connection.execute("SELECT pg_advisory_lock(#{DEMO_QUEUE_LOCK_KEY})")
    yield
  ensure
    ActiveRecord::Base.connection.execute("SELECT pg_advisory_unlock(#{DEMO_QUEUE_LOCK_KEY})")
  end
end
```

Use the advisory lock around read-modify-write operations in `refill_queue`, `take_demo`, and `ensure_queue` to avoid two requests claiming the same demo group ID.

Important behavior to preserve:

- `refill_queue` should still pre-cache translations.
- `ensure_queue` should still discard IDs for groups that no longer exist.
- If the cache is empty or lost, `ensure_queue`/`refill_queue` can rebuild it.

## ThrottleService

`ThrottleService` currently uses Redis counters:

```rb
Redis::Counter.new(k).increment(inc)
Redis::Counter.new(k).value <= ENV.fetch('THROTTLE_MAX_'+key, max)
```

Move it to Rails cache counters backed by Solid Cache.

Suggested behavior:

```rb
module ThrottleService
  PERIODS = {
    "hour" => 1.hour,
    "day" => 1.day
  }.freeze

  def self.cache_key(per:, key:, id:)
    "throttle:#{per}:#{key}:#{id}"
  end

  def self.reset!(per)
    # Solid Cache does not provide Redis-style scan/delete semantics.
    # Prefer targeted deletes in tests or versioned namespace invalidation.
  end

  def self.can?(key:, id:, max:, per:, inc: 1)
    per = per.to_s
    expires_in = PERIODS.fetch(per) do
      raise "Throttle per is not hour or day: #{per}"
    end

    limit = ENV.fetch("THROTTLE_MAX_#{key}", max).to_i
    count = Rails.cache.increment(cache_key(per: per, key: key, id: id), inc, expires_in: expires_in)

    count.to_i <= limit
  end
end
```

Implementation detail to verify with Solid Cache:

- Confirm `Rails.cache.increment(..., expires_in:)` sets an expiry when the key is first created.
- If Solid Cache does not handle this as needed, fall back to explicit `fetch`/`write` with a small lock or use a small DB table for strict throttles.

### Resetting throttles

The current Redis implementation can scan and delete all throttle keys for a period:

```rb
scan_each(match: "THROTTLE-#{per.upcase}*")
```

Solid Cache should not be treated as a Redis keyspace. Prefer one of these:

1. **Targeted reset** for tests and known IDs:
   - `Rails.cache.delete(ThrottleService.cache_key(...))`
2. **Versioned namespace reset**:
   - store a namespace/version per period and include it in the cache key
   - bump the namespace to invalidate all counters for a period
3. **Whole cache clear in dev/test only**:
   - acceptable for Nightwatch scenario setup if cache contains only transient test state

For production app code, avoid relying on broad key scans.

## Dev/Nightwatch reset

Replace `Dev::NightwatchController#redis_flushall` with explicit transient-state reset.

Current:

```rb
def redis_flushall
  CACHE_REDIS_POOL.with do |client|
    client.flushall
  end
end
```

Target concept:

```rb
def reset_transient_state
  Rails.cache.clear
end
```

If cache clearing becomes too broad, split it into service-level resets:

```rb
DemoService.reset_queue!
ThrottleService.reset_all!
```

## Tests to update

Current tests that directly reference Redis setup:

- `test/services/record_cloner_test.rb`
- `test/services/throttle_service_test.rb`

Replace direct `CACHE_REDIS_POOL` cleanup with Rails cache cleanup or targeted cache key deletion.

For example:

```rb
Rails.cache.clear
```

or:

```rb
Rails.cache.delete(ThrottleService.cache_key(per: "day", key: "UserInviterInvitations", id: @user.id))
Rails.cache.delete(ThrottleService.cache_key(per: "hour", key: "UserInviterInvitations", id: @user.id))
```

## Removal checklist

1. Add Solid Cache and Solid Cable gems/installers/migrations.
2. Change Rails cache store to `:solid_cache_store`.
3. Change Action Cable adapter to Solid Cable.
4. Replace `DemoService` Redis list with `Rails.cache` array plus advisory lock.
5. Replace `ThrottleService` Redis counters with `Rails.cache.increment` backed by Solid Cache.
6. Replace dev/nightwatch Redis flush with cache/transient-state reset.
7. Update tests that call `CACHE_REDIS_POOL`.
8. Remove `redis-objects` from `Gemfile`.
9. Remove `CACHE_REDIS_POOL` and `Redis::Objects.redis` setup.
10. Remove Redis service containers from GitHub Actions.
11. Remove Redis from `DEVSETUP.md` required dependencies.
12. Remove Redis environment variables from checked-in examples/docs unless they are explicitly documented as optional cache-backend overrides.
13. Verify no remaining app references to Redis:

```sh
grep -R "Redis\|redis\|CACHE_REDIS_POOL\|redis-objects" .
```

Expected remaining matches after cleanup should be documentation/changelog only.

## Validation

Run Rails tests and E2E tests separately.

Suggested targeted tests:

```sh
bin/rails test test/services/throttle_service_test.rb
bin/rails test test/services/record_cloner_test.rb
```

Then broader Rails tests.

Only after Rails tests finish, run E2E tests as needed:

```sh
bin/e2e notifications.js
```
