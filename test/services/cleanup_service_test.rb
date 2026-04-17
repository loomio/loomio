require 'test_helper'

class CleanupServiceTest < ActiveSupport::TestCase
  setup do
    @hex = SecureRandom.hex(4)
  end

  # -- unused_trial_group_ids --

  test "unused_trial_group_ids includes old single-member groups" do
    user = User.create!(name: "u#{@hex}", email: "u#{@hex}@example.com", username: "u#{@hex}")
    group = Group.create!(name: "Old Trial #{@hex}", handle: "old-trial-#{@hex}", creator: user, group_privacy: 'secret')
    Membership.create!(group: group, user: user, admin: true)
    group.update_column(:created_at, 4.years.ago)

    assert_includes CleanupService.unused_trial_group_ids, group.id
  end

  test "unused_trial_group_ids excludes groups less than 3 years old" do
    user = User.create!(name: "u#{@hex}", email: "u#{@hex}@example.com", username: "u#{@hex}")
    group = Group.create!(name: "Recent #{@hex}", handle: "recent-#{@hex}", creator: user, group_privacy: 'secret')
    Membership.create!(group: group, user: user, admin: true)
    group.update_column(:created_at, 2.years.ago)

    assert_not_includes CleanupService.unused_trial_group_ids, group.id
  end

  test "unused_trial_group_ids excludes groups with multiple members" do
    user = User.create!(name: "u#{@hex}", email: "u#{@hex}@example.com", username: "u#{@hex}")
    user2 = User.create!(name: "u2#{@hex}", email: "u2#{@hex}@example.com", username: "u2#{@hex}")
    group = Group.create!(name: "Multi #{@hex}", handle: "multi-#{@hex}", creator: user, group_privacy: 'secret')
    Membership.create!(group: group, user: user, admin: true)
    Membership.create!(group: group, user: user2)
    group.update_column(:created_at, 4.years.ago)

    assert_not_includes CleanupService.unused_trial_group_ids, group.id
  end

  test "unused_trial_group_ids excludes groups with real discussions" do
    user = User.create!(name: "u#{@hex}", email: "u#{@hex}@example.com", username: "u#{@hex}", email_verified: true)
    group = Group.create!(name: "Active #{@hex}", handle: "active-#{@hex}", creator: user, group_privacy: 'secret')
    Membership.create!(group: group, user: user, admin: true)
    group.update_column(:created_at, 4.years.ago)

    3.times do |i|
      DiscussionService.create(discussion: Discussion.new(title: "Real discussion #{i} #{@hex}", group: group, private: true), actor: user)
    end

    assert_not_includes CleanupService.unused_trial_group_ids, group.id
  end

  test "unused_trial_group_ids ignores default discussion titles" do
    user = User.create!(name: "u#{@hex}", email: "u#{@hex}@example.com", username: "u#{@hex}", email_verified: true)
    group = Group.create!(name: "Default #{@hex}", handle: "default-#{@hex}", creator: user, group_privacy: 'secret')
    Membership.create!(group: group, user: user, admin: true)
    group.update_column(:created_at, 4.years.ago)

    DiscussionService.create(discussion: Discussion.new(title: "How to use Loomio", group: group, private: true), actor: user)
    DiscussionService.create(discussion: Discussion.new(title: "Welcome! Please introduce yourself", group: group, private: true), actor: user)

    assert_includes CleanupService.unused_trial_group_ids, group.id
  end

  # -- expired_trial_group_ids --

  test "expired_trial_group_ids includes groups between 1 and 3 years old" do
    user = User.create!(name: "u#{@hex}", email: "u#{@hex}@example.com", username: "u#{@hex}")
    group = Group.create!(name: "Expired #{@hex}", handle: "expired-#{@hex}", creator: user, group_privacy: 'secret')
    Membership.create!(group: group, user: user, admin: true)
    group.update_column(:created_at, 2.years.ago)

    assert_includes CleanupService.expired_trial_group_ids, group.id
  end

  test "expired_trial_group_ids excludes groups less than 1 year old" do
    user = User.create!(name: "u#{@hex}", email: "u#{@hex}@example.com", username: "u#{@hex}")
    group = Group.create!(name: "New #{@hex}", handle: "new-#{@hex}", creator: user, group_privacy: 'secret')
    Membership.create!(group: group, user: user, admin: true)
    group.update_column(:created_at, 6.months.ago)

    assert_not_includes CleanupService.expired_trial_group_ids, group.id
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

  # -- spam_group_ids --

  test "spam_group_ids detects bulk group creators" do
    spammer = User.create!(name: "spammer#{@hex}", email: "spammer#{@hex}@example.com", username: "spammer#{@hex}")
    group_ids = []

    10.times do |i|
      g = Group.create!(name: "Spam#{i} #{@hex}", handle: "spam#{i}-#{@hex}", creator: spammer, group_privacy: 'secret')
      Membership.create!(group: g, user: spammer, admin: true)
      group_ids << g.id
    end

    detected = CleanupService.spam_group_ids
    group_ids.each do |id|
      assert_includes detected, id
    end
  end

  test "spam_group_ids excludes loomio.org staff groups" do
    staff = User.create!(name: "staff#{@hex}", email: "staff#{@hex}@loomio.org", username: "staff#{@hex}")
    group_ids = []

    10.times do |i|
      g = Group.create!(name: "Staff#{i} #{@hex}", handle: "staff#{i}-#{@hex}", creator: staff, group_privacy: 'secret')
      Membership.create!(group: g, user: staff, admin: true)
      group_ids << g.id
    end

    detected = CleanupService.spam_group_ids
    group_ids.each do |id|
      assert_not_includes detected, id
    end
  end

  test "spam_group_ids detects content spam groups" do
    user = User.create!(name: "content#{@hex}", email: "content#{@hex}@example.com", username: "content#{@hex}", email_verified: true)
    group = Group.create!(name: "Content Spam #{@hex}", handle: "content-spam-#{@hex}", creator: user, group_privacy: 'secret')
    Membership.create!(group: group, user: user, admin: true)

    10.times do |i|
      DiscussionService.create(discussion: Discussion.new(title: "Spam post #{i} #{@hex}", group: group, private: true), actor: user)
    end

    assert_includes CleanupService.spam_group_ids, group.id
  end

  test "spam_group_ids detects keyword spam groups" do
    user = User.create!(name: "kw#{@hex}", email: "kw#{@hex}@example.com", username: "kw#{@hex}", email_verified: true)
    group = Group.create!(name: "KW Spam #{@hex}", handle: "kw-spam-#{@hex}", creator: user, group_privacy: 'secret')
    Membership.create!(group: group, user: user, admin: true)

    DiscussionService.create(discussion: Discussion.new(title: "Buy cheap viagra now", group: group, private: true), actor: user)

    assert_includes CleanupService.spam_group_ids, group.id
  end

  test "spam_group_ids excludes groups with many members" do
    user = User.create!(name: "legit#{@hex}", email: "legit#{@hex}@example.com", username: "legit#{@hex}", email_verified: true)
    group = Group.create!(name: "Legit #{@hex}", handle: "legit-#{@hex}", creator: user, group_privacy: 'secret')
    Membership.create!(group: group, user: user, admin: true)

    4.times do |i|
      m = User.create!(name: "m#{i}#{@hex}", email: "m#{i}#{@hex}@example.com", username: "m#{i}#{@hex}")
      Membership.create!(group: group, user: m)
    end

    DiscussionService.create(discussion: Discussion.new(title: "Buy cheap viagra now", group: group, private: true), actor: user)

    assert_not_includes CleanupService.spam_group_ids, group.id
  end
end
