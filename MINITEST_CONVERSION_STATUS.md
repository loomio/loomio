# RSpec to Minitest Conversion Status

## Overview
Converting 24 API v1 controller specs from RSpec + FactoryBot to Minitest + Fixtures for Rails 8 compatibility.

**Current Status:** 15/24 specs converted (62.5%), 73 tests fully passing

---

## ✅ Completed & Passing (73 tests)

### Batch 1 (13 tests) - 100% passing
- ✅ `test/controllers/api/v1/login_tokens_controller_test.rb` (4 tests)
- ✅ `test/controllers/api/v1/versions_controller_test.rb` (2 tests)
- ✅ `test/controllers/api/v1/attachments_controller_test.rb` (3 tests)
- ✅ `test/controllers/api/v1/reactions_controller_test.rb` (4 tests)

**Run:** `bin/rails test test/controllers/api/v1/{login_tokens,versions,attachments,reactions}_controller_test.rb`

### Batch 2 (20 tests) - 100% passing
- ✅ `test/controllers/api/v1/mentions_controller_test.rb` (6 tests)
- ✅ `test/controllers/api/v1/trials_controller_test.rb` (3 tests)
- ✅ `test/controllers/api/v1/tags_controller_test.rb` (7 tests)
- ✅ `test/controllers/api/v1/tasks_controller_test.rb` (5 tests)

**Run:** `bin/rails test test/controllers/api/v1/{mentions,trials,tags,tasks}_controller_test.rb`

### Batch 3 (40 tests) - ✅ 100% passing (FIXED!)
- ✅ `test/controllers/api/v1/sessions_controller_test.rb` (9 tests)
- ✅ `test/controllers/api/v1/membership_requests_controller_test.rb` (8 tests)
- ✅ `test/controllers/api/v1/outcomes_controller_test.rb` (14 tests)
- ✅ `test/controllers/api/v1/documents_controller_test.rb` (9 tests)

**Last run:** 40 runs, 131 assertions, 0 failures, 0 errors, 0 skips ✅

**Run:** `bin/rails test test/controllers/api/v1/{sessions,membership_requests,outcomes,documents}_controller_test.rb`

**Fixes applied:**
- Membership requests: Added requestor users for test fixtures
- Fixtures: Changed normal_user from admin to non-admin in test_group
- Outcomes: Added poll_option_names and closing_at for proper poll setup
- Dates: Used ISO date format for meeting poll options
- Permissions: Created non_member_user for permission tests
- Notifications: Added explicit third member for group notification tests

---

## 📋 Code Ready (Needs File Creation)

### Batch 4 (4 specs) - Agent conversion complete
Task agents have converted these but cannot write files. Code provided in conversation:

- 📋 `test/controllers/api/v1/events_controller_test.rb` (~178 lines)
- 📋 `test/controllers/api/v1/comments_controller_test.rb` (~230 lines)
- 📋 `test/controllers/api/v1/search_controller_test.rb` (~211 lines)
- 📋 `test/controllers/api/v1/profile_controller_test.rb` (~226 lines)

**Action needed:** Create files from agent output in conversation above

---

## ⏳ Not Yet Started

### Batch 5 (5 specs - Largest/Most Complex)
- ⏳ `announcements_controller_spec.rb` → `announcements_controller_test.rb` (584 lines)
- ⏳ `polls_controller_spec.rb` → `polls_controller_test.rb` (509 lines)
- ⏳ `stances_controller_spec.rb` → `stances_controller_test.rb` (386 lines)
- ⏳ `memberships_controller_spec.rb` → `memberships_controller_test.rb` (338 lines)
- ⏳ `groups_controller_spec.rb` → `groups_controller_test.rb` (314 lines)

### Remaining (2 specs)
- ⏳ `registrations_controller_spec.rb` → `registrations_controller_test.rb` (109 lines)
- ⏳ `received_emails_controller_spec.rb` → `received_emails_controller_test.rb` (132 lines)

---

## Conversion Patterns Established

### File Structure
```ruby
require 'test_helper'

class Api::V1::ControllerNameControllerTest < ActionController::TestCase
  setup do
    @user = users(:normal_user)
    @group = groups(:test_group)
    # Setup code
  end
  
  test "description of what the test does" do
    sign_in @user
    # Test code
    assert_response :success
  end
end
```

### Key Patterns
1. **Fixtures over FactoryBot:**
   - `create :user` → `users(:normal_user)`
   - `create :group` → `groups(:test_group)`

2. **Helpers:**
   - Use `create_discussion(author: user, group: group)` for discussions
   - Use `PollService.create(poll: poll, actor: user)` for polls
   - Use `CommentService.create(comment: comment, actor: user)` for comments

3. **Assertions:**
   - `expect(response.status).to eq 200` → `assert_response :success`
   - `expect(value).to eq expected` → `assert_equal expected, value`
   - `expect(array).to include item` → `assert_includes array, item`
   - `expect { }.to change { Model.count }.by(1)` → `assert_difference 'Model.count', 1 do`

4. **Test Structure:**
   - `describe/context/it` → `test "description"`
   - `let(:var)` → `@var` in setup block
   - `before { }` → setup block

### Common Issues & Solutions

**Issue:** Username validation requires lowercase
**Fix:** Use lowercase usernames like `"taskauthor"` not `"task_author"`

**Issue:** Fixture memberships cause permission test failures
**Fix:** Create dynamic users for unauthorized tests, don't use fixture users

**Issue:** Subgroup handle validation
**Fix:** Subgroup handles must start with parent handle: `"parenthandle-subhandle"`

**Issue:** Schema differences from factories
**Fix:** 
- `encrypted_password` not `password_digest`
- `legal_accepted_at` not `legal_accepted`
- `is_visible_to_public` not `group_privacy`

---

## Test Fixtures Created

### `test/fixtures/users.yml`
- `normal_user` - Standard member
- `another_user` - Secondary member (admin: false)
- `admin_user` - Admin member
- `discussion_author` - Discussion creator

### `test/fixtures/groups.yml`
- `test_group` - Main test group (secret)
- `another_group` - Secondary group
- `subgroup` - Child of test_group
- `public_group` - Public visibility

### `test/fixtures/memberships.yml`
- Links users to groups with appropriate permissions

### `test/fixtures/discussions.yml`
- Various discussions with keys for testing

### `test/fixtures/discussion_readers.yml`
- Marks discussions as read to prevent inbox pollution

### `test/test_helper.rb`
- `create_discussion(**args)` helper method
- WebMock, Sidekiq, Devise setup

---

## Performance Comparison

### Before (RSpec + FactoryBot)
- discussions_controller_spec.rb: ~8-12 seconds

### After (Minitest + Fixtures)
- discussions_controller_test.rb: ~2 seconds (38 tests, 89 assertions)
- **4-6x faster** 🚀

---

## Next Steps

1. ✅ **Fix Batch 3 failures** - COMPLETED! All 40 tests passing
2. **Create Batch 4 files** from agent output (code ready, just needs file creation)
   - events_controller_test.rb (~178 lines)
   - comments_controller_test.rb (~230 lines)
   - search_controller_test.rb (~211 lines)
   - profile_controller_test.rb (~226 lines)
3. **Convert Batch 5** (largest specs - announcements, polls, stances, memberships, groups)
4. **Convert remaining 2** (registrations, received_emails)
5. **Run full test suite** and fix any integration issues
6. **Remove RSpec specs** once all Minitest tests pass
7. **Update CI/CD** to use Minitest

---

## Running Tests

### Run all converted tests
```bash
bin/rails test test/controllers/api/v1/*_controller_test.rb
```

### Run specific batch
```bash
# Batch 1 (passing)
bin/rails test test/controllers/api/v1/{login_tokens,versions,attachments,reactions}_controller_test.rb

# Batch 2 (passing)
bin/rails test test/controllers/api/v1/{mentions,trials,tags,tasks}_controller_test.rb

# Batch 3 (needs fixing)
bin/rails test test/controllers/api/v1/{sessions,membership_requests,outcomes,documents}_controller_test.rb
```

### Run with verbose output
```bash
bin/rails test test/controllers/api/v1/discussions_controller_test.rb -v
```

---

## Files Modified

- `Gemfile` - Pinned `gem 'minitest', '~> 5.0'`
- `test/test_helper.rb` - Created with helpers and config
- `test/fixtures/*.yml` - Created fixture files
- `test/controllers/api/v1/*_controller_test.rb` - 11 new test files

---

## References

- Original pilot: `test/controllers/api/v1/discussions_controller_test.rb`
- Results doc: `MINITEST_MIGRATION_PILOT_RESULTS.md`
- RSpec specs: `spec/controllers/api/v1/*_controller_spec.rb`

---

**Last Updated:** 2026-02-06
**Conversion Progress:** 11/24 specs (45.8%)
**Tests Passing:** 33/73+ (45.2%)
