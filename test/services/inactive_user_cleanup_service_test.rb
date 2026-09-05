require "test_helper"

class InactiveUserCleanupServiceTest < ActiveSupport::TestCase
  MEMBERSHIP_MATRIX_USERS = %i[
    member_quiet
    member_normal
    member_loud
    alien_quiet
    alien_loud
    former_member_loud
    inactive_member_loud
    reader_quiet
    reader_normal
    reader_loud
    member_guest_loud
    former_member_guest
  ].freeze

  DIRECT_TOPIC_MATRIX_USERS = %i[
    guest_quiet
    guest_normal
    guest_admin_normal
    guest_loud
    non_guest_loud
    former_guest_loud
    inactive_guest_loud
  ].freeze

  ALIEN_MATRIX_USERS = %i[alien_quiet alien_loud].freeze

  test "applies the inactive account state matrix" do
    matrix = {
      old_orphan: { user: users(:orphan_user), eligible: true },
      recent_orphan: { user: users(:orphan_recent_user), eligible: false },
      old_former_invitee: { user: users(:orphan_former_invitee_user), eligible: true },
      recent_former_invitee: { user: users(:orphan_recent_invitee_user), eligible: false },
      deactivated_old_orphan: { user: users(:orphan_deactivated_user), eligible: true },
      deactivated_recent_orphan: { user: users(:orphan_recent_deactivated_user), eligible: false }
    }
    candidate_ids = InactiveUserCleanupService.orphan_user_ids

    matrix.each do |name, entry|
      assert_equal entry[:eligible], candidate_ids.include?(entry[:user].id), name
    end
  end

  test "requires the last sign in to be older than the cutoff" do
    cutoff = Time.zone.local(2025, 9, 5, 12)
    user = users(:orphan_cutoff_user)
    user.update_column(:last_sign_in_at, cutoff)

    assert_not_includes InactiveUserCleanupService.orphan_user_ids(inactive_before: cutoff), user.id

    user.update_column(:last_sign_in_at, cutoff - 1.second)

    assert_includes InactiveUserCleanupService.orphan_user_ids(inactive_before: cutoff), user.id
  end

  test "uses account age for former invitees who never signed in" do
    cutoff = Time.zone.local(2025, 9, 5, 12)
    user = users(:orphan_recent_invitee_user)
    user.update_column(:created_at, cutoff)

    assert_not_includes InactiveUserCleanupService.orphan_user_ids(inactive_before: cutoff), user.id

    user.update_column(:created_at, cutoff - 1.second)

    assert_includes InactiveUserCleanupService.orphan_user_ids(inactive_before: cutoff), user.id
  end

  test "preserves every membership role in the reusable user matrix" do
    users = MEMBERSHIP_MATRIX_USERS.map { |name| users(name) }
    users.each { |user| user.update_columns(last_sign_in_at: 2.years.ago, deactivated_at: nil) }
    candidate_ids = InactiveUserCleanupService.orphan_user_ids

    users.each do |user|
      assert Membership.where(user_id: user.id).exists?, "#{user.username} must have membership history"
      assert_not_includes candidate_ids, user.id, user.username
    end


    ALIEN_MATRIX_USERS.each do |name|
      user = users(name)
      assert Membership.where(user: user, group: groups(:alien_group)).exists?, "#{name} must belong to alien_group"
      assert_not Membership.where(user: user, group: groups(:group)).exists?, "#{name} must remain outside the primary group"
    end
  end

  test "preserves every direct-topic participant in the reusable user matrix" do
    direct_topic = topics(:direct_topic)
    users = DIRECT_TOPIC_MATRIX_USERS.map { |name| users(name) }
    users.each { |user| user.update_columns(last_sign_in_at: 2.years.ago, deactivated_at: nil) }
    candidate_ids = InactiveUserCleanupService.orphan_user_ids

    users.each do |user|
      assert TopicReader.where(topic: direct_topic, user: user).exists?, "#{user.username} must participate in the direct topic"
      assert_not_includes candidate_ids, user.id, user.username
    end
  end
end
