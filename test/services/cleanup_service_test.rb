require 'test_helper'

class CleanupServiceTest < ActiveSupport::TestCase
  setup do
    @hex = SecureRandom.hex(4)
  end

  def build_inactive_user
    user = User.create!(
      name: "u#{@hex}",
      email: "u#{@hex}@example.com",
      username: "u#{@hex}",
      email_verified: true
    )
    user.update_column(:last_sign_in_at, 2.years.ago)
    user
  end

  # -- orphan_user_ids --

  test "includes long-inactive users with no memberships or content" do
    user = build_inactive_user
    assert_includes CleanupService.orphan_user_ids, user.id
  end

  test "excludes users with any membership (even revoked)" do
    user = build_inactive_user
    Membership.create!(group: groups(:test_group), user: user, revoked_at: 1.year.ago)

    assert_not_includes CleanupService.orphan_user_ids, user.id
  end

  test "excludes users with comments" do
    user = build_inactive_user
    Comment.new(
      body: "hi #{@hex}",
      parent: discussions(:test_discussion),
      discussion: discussions(:test_discussion),
      user: user
    ).save!(validate: false)

    assert_not_includes CleanupService.orphan_user_ids, user.id
  end

  test "excludes users who authored a discussion" do
    user = build_inactive_user
    Discussion.new(
      title: "d #{@hex}",
      group: groups(:test_group),
      author: user,
      private: true,
      key: SecureRandom.hex(8)
    ).save!(validate: false)

    assert_not_includes CleanupService.orphan_user_ids, user.id
  end

  test "excludes users who authored a poll" do
    user = build_inactive_user
    Poll.new(
      title: "p #{@hex}",
      poll_type: "proposal",
      author: user,
      group: groups(:test_group),
      closing_at: 1.day.from_now,
      key: SecureRandom.hex(8)
    ).save!(validate: false)

    assert_not_includes CleanupService.orphan_user_ids, user.id
  end

  test "excludes users with a stance" do
    user = build_inactive_user
    poll = Poll.new(
      title: "p #{@hex}",
      poll_type: "proposal",
      author: users(:discussion_author),
      group: groups(:test_group),
      closing_at: 1.day.from_now,
      key: SecureRandom.hex(8)
    )
    poll.save!(validate: false)
    Stance.new(poll: poll, participant: user, latest: true).save!(validate: false)

    assert_not_includes CleanupService.orphan_user_ids, user.id
  end

  test "excludes recently active users" do
    user = User.create!(name: "recent#{@hex}", email: "recent#{@hex}@example.com", username: "recent#{@hex}")
    user.update_column(:last_sign_in_at, 1.month.ago)

    assert_not_includes CleanupService.orphan_user_ids, user.id
  end

  test "excludes deactivated users" do
    user = User.create!(name: "deact#{@hex}", email: "deact#{@hex}@example.com", username: "deact#{@hex}")
    user.update_columns(last_sign_in_at: 2.years.ago, deactivated_at: 1.year.ago)

    assert_not_includes CleanupService.orphan_user_ids, user.id
  end
end
