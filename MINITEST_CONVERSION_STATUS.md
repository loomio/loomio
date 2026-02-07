# RSpec to Minitest Conversion Status

## Overview
Comprehensive conversion of RSpec test suite to Minitest + Fixtures for Rails 8 compatibility.

**Status: COMPLETE — All RSpec specs converted to Minitest**
- **API v1 Controllers:** 24/24 specs converted (100%)
- **Services:** 22/22 converted (100%)
- **Models:** 25/25 specs converted (100%)
- **Other Controllers:** 24/24 converted (100%) — B2/B3 API, identity, email, groups, memberships, polls, discussions, hocuspocus, dev mailer tests
- **Extras/Helpers/Queries:** 11/11 converted (100%)
- **Mailers:** 1/1 converted (100%)
- **Mailboxes:** 2/2 converted (100%)
- **Workers:** 1/1 converted (100%)
- **Total: 1040 runs, 3467 assertions, 0 failures, 0 errors**

**Performance:** 4-6x faster than RSpec with FactoryBot

**GitHub Actions:** `.github/workflows/minitest.yml`

---

## Recent Fixes (2026-02-06)

### Fixed: tags_controller_test.rb (was 7 tests failing)
- **Root cause:** `@group.add_admin!(@user) unless @group.members.include?(@user)` — since fixture user was already a member (admin: false), the admin promotion was skipped
- **Fix:** Unconditional `@group.add_admin!(@user)`
- **Result:** 6 tests passing

### Expanded: stances_controller_test.rb (1 → 18 tests)
- Added: index (3), admin actions with permission checks (6), uncast (3), create (6)
- Key pattern: use `@poll.stances.find_by(participant_id: voter.id)` for auto-created stances

### Converted: poll_service_test.rb (new, 26 tests)
- Covers: create_stances (7), create (5), update (5), close (4), expire_lapsed_polls (3), group_members_added (2)
- Key pattern: use `specified_voters_only: true` polls for create_stances tests to avoid auto-creation

### Expanded: discussion_service_test.rb (10 → 25 tests)
- Added: authorization (2), mentions (2), volume (2), update with version tracking (5), update_reader (2), move with privacy/permissions/polls (8), close/reopen (2)

### Expanded: stance_service_test.rb (2 → 7 tests)
- Added: create (1), event parent (1), total_score (1), redeem guest (1), redeem non-guest (1)
- Key insight: `add_member!` triggers `PollService.group_members_added` via Sidekiq inline, auto-creating stances. Don't add voter to group in redeem tests.

### Expanded: record_cloner_test.rb (2 → 4 tests)
- Added: full group cloning (1), discussion with events/comments (1), poll stances/outcomes (1)
- Uses fresh group (not fixture) to avoid fixture discussions without created_events
- Key insight: use only `choice=` setter, not `stance_choices.build` (avoids dots_per_person violation on proposals)

### Converted: events_controller_test.rb (new, 12 tests)
- Covers: pin, index (5), comment (2), logged out access (2), cross-discussion isolation (1), discussion reader (1)
- Key insight: groups with `is_visible_to_public: false` reject `private: false` discussions silently; use `public_group` fixture for public discussion tests

### Converted: received_email_service_test.rb (new, 10 tests)
- Covers: reply body splitting (7), subject stripping (1), email routing integration (3)

### Batch 8: Remaining hard specs (2026-02-06)

#### Discussion mailer test (6 tests)
- `test/controllers/dev/discussion_mailer_test.rb`
- Tests Dev::NightwatchController endpoints that set up discussion data and render emails
- Assertions via Nokogiri CSS selectors on rendered email HTML
- Covers: discussion_created, discussion_announced, invitation_created, new_comment, user_mentioned, comment_replied_to

#### Poll mailer test (119 tests)
- `test/controllers/dev/poll_mailer_test.rb`
- Tests Dev::PollsController test_poll_scenario endpoint across 7 poll types × 17 scenarios
- Poll types: proposal, poll, dot_vote, score, count, meeting, ranked_choice
- Scenarios: created, anonymous created, outcome_created, outcome_review_due, anonymous outcome, stance_created, anonymous stance, results_hidden stance, closing_soon (3 variants), closing_soon_author, user_mentioned (3 variants), expired_author, anonymous expired

#### Group export service test (1 test)
- `test/services/group_export_service_test.rb`
- Tests full export → selective delete → import cycle
- Uses targeted record deletion (not TRUNCATE) to preserve fixtures
- Verifies all imported entities: users, groups, memberships, discussions, comments, polls, stances, templates, tags, reactions

#### Migrate user worker test (1 test)
- `test/workers/migrate_user_worker_test.rb`
- Tests merging all references from source user → destination user
- Verifies: comments, memberships, reactions, polls, outcomes, stances, identities, discussion readers, membership requests, versions, sign_in_count, deactivation

---

## Conversion Patterns

### File Structure
```ruby
require 'test_helper'

class Api::V1::ControllerNameControllerTest < ActionController::TestCase
  setup do
    @user = users(:normal_user)
    @group = groups(:test_group)
  end

  test "description" do
    sign_in @user
    assert_response :success
  end
end
```

### Key Patterns
1. **Fixtures over FactoryBot:** `create :user` → `users(:normal_user)`
2. **Helpers:** `create_discussion(author: user, group: group)` for discussions
3. **Assertions:** `expect(x).to eq y` → `assert_equal y, x`
4. **Test Structure:** `describe/it` → `test "description"`

### Common Pitfalls
- **Admin promotion:** Always use unconditional `@group.add_admin!(@user)` (fixture user may be member with admin: false)
- **Auto-created stances:** Polls auto-create stances for group members. Use `specified_voters_only: true` when testing `create_stances`
- **Discussion privacy:** Groups with `is_visible_to_public: false` silently fail `private: false` discussions. Use `public_group` fixture for public tests.
- **Dots per person:** On proposal polls, use only `stance.choice = 'Agree'`, never combine with `stance_choices.build` (exceeds dots_per_person: 1)
- **add_member! side effects:** Triggers `PollService.group_members_added` via Sidekiq inline, which creates stances on existing polls
- **Throttle limits:** Long test sessions may hit `UserInviterInvitations` throttle. Reset with: `CACHE_REDIS_POOL.with { |r| r.del("THROTTLE-DAY-UserInviterInvitations-#{user.id}") }`
- **Unique values:** Use `SecureRandom.hex(4)` for unique handles/emails/usernames
- **Subgroup handles:** Must start with parent handle: `"parenthandle-subhandle"`
- **loomio_subs engine:** Affects subscription/privacy behavior; prefer secret/private groups in tests

---

## Test Fixtures & Helpers

### Main Fixtures
- `users(:normal_user, :another_user, :admin_user, :discussion_author)`
- `groups(:test_group, :another_group, :subgroup, :public_group)`

### Helpers (`test/test_helper.rb`)
- `create_discussion(**args)` - Creates discussion + events

---

## Running Tests

```bash
# Everything
bin/rails test

# All controllers
bin/rails test test/controllers/api/v1/*_controller_test.rb

# All services
bin/rails test test/services/*_test.rb

# Single file verbose
bin/rails test test/services/poll_service_test.rb -v
```

---

## Model Specs Converted (2026-02-06)

### Batch 1: Simple models (30 tests)
- `test/models/login_token_test.rb` (5 tests)
- `test/models/membership_test.rb` (5 tests)
- `test/models/stance_test.rb` (6 tests)
- `test/models/stance_choice_test.rb` (3 tests)
- `test/models/outcome_test.rb` (2 tests)
- `test/models/poll_option_test.rb` (1 test)
- `test/models/has_avatar_test.rb` (4 tests)
- `test/models/events/new_coordinator_test.rb` (2 tests)
- `test/models/events/invitation_accepted_test.rb` (2 tests)

### Batch 2: Core models (61 tests)
- `test/models/user_test.rb` (27 tests)
- `test/models/group_test.rb` (16 tests)
- `test/models/group_privacy_test.rb` (13 tests)
- `test/models/comment_test.rb` (7 tests) — note: `has_gravatar?` returns false in test env

### Batch 3: Discussion-related (31 tests)
- `test/models/discussion_test.rb` (14 tests)
- `test/models/discussion_reader_test.rb` (15 tests)
- `test/models/discussion_event_integration_test.rb` (2 tests)

### Batch 4: Ability specs (75 tests, 190 assertions)
- `test/models/ability_test.rb` — group visibility, member/admin permissions
- `test/models/ability/poll_test.rb` — poll permissions across roles
- `test/models/ability/discussion_test.rb` — discussion permissions

### Batch 5: Event specs (40 tests)
- `test/models/event_test.rb` (19 tests) — email notifications, volumes, mentions, webhooks
- `test/models/events/new_comment_test.rb` (3 tests)
- `test/models/events/comment_replied_to_test.rb` (5 tests)
- `test/models/events/group_mentioned_test.rb` (6 tests)
- `test/models/concerns/events/position_test.rb` (7 tests)

### Key fixes during model conversion
- **WebMock:** Changed `require "webmock"` to `require "webmock/minitest"` in test_helper.rb — the plain require doesn't call `WebMock.enable!` so Net::HTTP is never patched
- **Poll creation in event tests:** Use `@poll.save!` + `@poll.create_missing_created_event!` instead of `PollService.create` to avoid publishing events/emails during setup
- **Proposal poll options:** Use lowercase names `%w[agree disagree abstain]` to match `common_poll_options` keys and get proper icons
- **Email delivery clearing:** Add `ActionMailer::Base.deliveries.clear` at end of test setup when setup creates objects that send emails

---

## Next Steps

1. Remove RSpec specs and Gemfile dependencies (rspec-rails, factory_bot_rails)
2. Switch CI/CD to Minitest-only
3. Clean up any remaining spec/ directory references

---

**Last Updated:** 2026-02-06
**Total: 1040 runs, 3467 assertions, 0 failures, 0 errors**
