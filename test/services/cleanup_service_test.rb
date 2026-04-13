require 'test_helper'

class CleanupServiceTest < ActiveSupport::TestCase
  setup do
    @hex = SecureRandom.hex(4)
  end

  # -- unused_trial_group_ids --

  test "unused_trial_group_ids includes old single-member groups" do
    user = User.create!(name: "u#{@hex}", email: "u#{@hex}@example.com", username: "u#{@hex}")
    group = Group.create!(name: "Old Trial #{@hex}", handle: "old-trial-#{@hex}", creator: user)
    group.add_admin!(user)
    group.update_column(:created_at, 4.years.ago)

    assert_includes CleanupService.unused_trial_group_ids, group.id
  end

  test "unused_trial_group_ids excludes groups less than 3 years old" do
    user = User.create!(name: "u#{@hex}", email: "u#{@hex}@example.com", username: "u#{@hex}")
    group = Group.create!(name: "Recent #{@hex}", handle: "recent-#{@hex}", creator: user)
    group.add_admin!(user)
    group.update_column(:created_at, 2.years.ago)

    assert_not_includes CleanupService.unused_trial_group_ids, group.id
  end

  test "unused_trial_group_ids excludes groups with multiple members" do
    user = User.create!(name: "u#{@hex}", email: "u#{@hex}@example.com", username: "u#{@hex}")
    user2 = User.create!(name: "u2#{@hex}", email: "u2#{@hex}@example.com", username: "u2#{@hex}")
    group = Group.create!(name: "Multi #{@hex}", handle: "multi-#{@hex}", creator: user)
    group.add_admin!(user)
    group.add_member!(user2)
    group.update_column(:created_at, 4.years.ago)

    assert_not_includes CleanupService.unused_trial_group_ids, group.id
  end

  test "unused_trial_group_ids excludes groups with real discussions" do
    user = User.create!(name: "u#{@hex}", email: "u#{@hex}@example.com", username: "u#{@hex}")
    group = Group.create!(name: "Active #{@hex}", handle: "active-#{@hex}", creator: user)
    group.add_admin!(user)
    group.update_column(:created_at, 4.years.ago)

    3.times do |i|
      Discussion.create!(title: "Real discussion #{i} #{@hex}", group: group, author: user, private: true)
    end

    assert_not_includes CleanupService.unused_trial_group_ids, group.id
  end

  test "unused_trial_group_ids ignores default discussion titles" do
    user = User.create!(name: "u#{@hex}", email: "u#{@hex}@example.com", username: "u#{@hex}")
    group = Group.create!(name: "Default #{@hex}", handle: "default-#{@hex}", creator: user)
    group.add_admin!(user)
    group.update_column(:created_at, 4.years.ago)

    Discussion.create!(title: "How to use Loomio", group: group, author: user, private: true)
    Discussion.create!(title: "Welcome! Please introduce yourself", group: group, author: user, private: true)

    assert_includes CleanupService.unused_trial_group_ids, group.id
  end

  # -- expired_trial_group_ids --

  test "expired_trial_group_ids includes groups between 1 and 3 years old" do
    user = User.create!(name: "u#{@hex}", email: "u#{@hex}@example.com", username: "u#{@hex}")
    group = Group.create!(name: "Expired #{@hex}", handle: "expired-#{@hex}", creator: user)
    group.add_admin!(user)
    group.update_column(:created_at, 2.years.ago)

    assert_includes CleanupService.expired_trial_group_ids, group.id
  end

  test "expired_trial_group_ids excludes groups less than 1 year old" do
    user = User.create!(name: "u#{@hex}", email: "u#{@hex}@example.com", username: "u#{@hex}")
    group = Group.create!(name: "New #{@hex}", handle: "new-#{@hex}", creator: user)
    group.add_admin!(user)
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
    group = groups(:test_group)
    group.add_member!(user)

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
      g = Group.create!(name: "Spam#{i} #{@hex}", handle: "spam#{i}-#{@hex}", creator: spammer)
      g.add_admin!(spammer)
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
      g = Group.create!(name: "Staff#{i} #{@hex}", handle: "staff#{i}-#{@hex}", creator: staff)
      g.add_admin!(staff)
      group_ids << g.id
    end

    detected = CleanupService.spam_group_ids
    group_ids.each do |id|
      assert_not_includes detected, id
    end
  end

  test "spam_group_ids detects content spam groups" do
    user = User.create!(name: "content#{@hex}", email: "content#{@hex}@example.com", username: "content#{@hex}")
    group = Group.create!(name: "Content Spam #{@hex}", handle: "content-spam-#{@hex}", creator: user)
    group.add_admin!(user)

    10.times do |i|
      Discussion.create!(title: "Spam post #{i} #{@hex}", group: group, author: user, private: true)
    end

    assert_includes CleanupService.spam_group_ids, group.id
  end

  test "spam_group_ids detects keyword spam groups" do
    user = User.create!(name: "kw#{@hex}", email: "kw#{@hex}@example.com", username: "kw#{@hex}")
    group = Group.create!(name: "KW Spam #{@hex}", handle: "kw-spam-#{@hex}", creator: user)
    group.add_admin!(user)

    Discussion.create!(title: "Buy cheap viagra now", group: group, author: user, private: true)

    assert_includes CleanupService.spam_group_ids, group.id
  end

  test "spam_group_ids excludes groups with many members" do
    user = User.create!(name: "legit#{@hex}", email: "legit#{@hex}@example.com", username: "legit#{@hex}")
    group = Group.create!(name: "Legit #{@hex}", handle: "legit-#{@hex}", creator: user)
    group.add_admin!(user)

    4.times do |i|
      m = User.create!(name: "m#{i}#{@hex}", email: "m#{i}#{@hex}@example.com", username: "m#{i}#{@hex}")
      group.add_member!(m)
    end

    Discussion.create!(title: "Buy cheap viagra now", group: group, author: user, private: true)

    assert_not_includes CleanupService.spam_group_ids, group.id
  end
end
