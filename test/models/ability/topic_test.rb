require "test_helper"
require_relative "../../support/access_volume_matrix"

class Ability::TopicTest < ActiveSupport::TestCase
  test "group coordination allows announcements independently of the member setting" do
    topic = topics(:discussion_topic)
    coordinator = users(:member_normal)
    member = users(:member_loud)
    topic.group.add_admin!(coordinator)
    topic.group.update!(members_can_announce: false)

    assert coordinator.can?(:announce, topic)
    assert_not member.can?(:announce, topic)
    assert_not users(:guest_admin_normal).can?(:announce, topic)
    topic.group.update!(members_can_announce: true)
    assert member.can?(:announce, topic)
  end

  test "adding existing members uses group membership for group topics and guest membership for direct topics" do
    group_members = %i[admin user member member_quiet member_normal member_loud reader_quiet reader_normal reader_loud member_guest_loud]
    direct_members = %i[guest_quiet guest_normal guest_admin_normal guest_loud]
    AccessVolumeMatrix::ROLES.each do |role|
      actor = users(role)
      assert_equal group_members.include?(role), actor.can?(:add_members, topics(:discussion_topic)), "group: #{role}"
      assert_equal direct_members.include?(role), actor.can?(:add_members, topics(:direct_topic)), "direct: #{role}"
    end
    [users(:server_admin), LoggedOutUser.new].each do |actor|
      assert_not actor.can?(:add_members, topics(:discussion_topic))
      assert_not actor.can?(:add_members, topics(:direct_topic))
    end
  end

  test "member discovery requires topic access and verification only for group topics" do
    actor = users(:guest_normal)
    group_topic = topics(:discussion_topic)
    direct_topic = topics(:direct_topic)
    assert actor.can?(:members_autocomplete, group_topic)
    assert actor.can?(:members_autocomplete, direct_topic)

    actor.update!(email_verified: false)
    assert_not actor.can?(:members_autocomplete, group_topic)
    assert actor.can?(:members_autocomplete, direct_topic)
    [users(:alien), users(:former_guest_loud), users(:non_guest_loud), LoggedOutUser.new].each do |outsider|
      assert_not outsider.can?(:members_autocomplete, group_topic)
      assert_not outsider.can?(:members_autocomplete, direct_topic)
    end
  end
end
