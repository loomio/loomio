require 'test_helper'

class CleanupServiceTest < ActiveSupport::TestCase
  setup do
    @hex = SecureRandom.hex(4)
  end

  # -- orphan_user_ids --

  test "orphan_user_ids includes users with no memberships and old sign in" do
    user = User.create!(name: "orphan#{@hex}", email: "orphan#{@hex}@example.com", username: "orphan#{@hex}")
    user.update_column(:last_sign_in_at, 2.years.ago)

    assert_includes CleanupService.orphan_user_ids, user.id
  end

  test "orphan_user_ids excludes users with active memberships" do
    user = User.create!(name: "member#{@hex}", email: "member#{@hex}@example.com", username: "member#{@hex}")
    user.update_column(:last_sign_in_at, 2.years.ago)
    Membership.create!(group: groups(:test_group), user: user)

    assert_not_includes CleanupService.orphan_user_ids, user.id
  end

  test "orphan_user_ids excludes recently active users" do
    user = User.create!(name: "recent#{@hex}", email: "recent#{@hex}@example.com", username: "recent#{@hex}")
    user.update_column(:last_sign_in_at, 1.month.ago)

    assert_not_includes CleanupService.orphan_user_ids, user.id
  end

  test "orphan_user_ids excludes deactivated users" do
    user = User.create!(name: "deact#{@hex}", email: "deact#{@hex}@example.com", username: "deact#{@hex}")
    user.update_columns(last_sign_in_at: 2.years.ago, deactivated_at: 1.year.ago)

    assert_not_includes CleanupService.orphan_user_ids, user.id
  end
end
