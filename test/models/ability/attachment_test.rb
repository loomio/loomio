require "test_helper"
require_relative "../../support/access_volume_matrix"

class Ability::AttachmentTest < ActiveSupport::TestCase
  test "group attachments require membership to read and coordination to delete" do
    attachment = Attachment.new(record: topics(:discussion_topic).topicable)
    members = %i[admin user member member_quiet member_normal member_loud reader_quiet reader_normal reader_loud member_guest_loud]
    # Authentication rejects deactivated accounts before their ability is used.
    roles = AccessVolumeMatrix::ROLES - %i[inactive_member_loud inactive_guest_loud]

    roles.each do |role|
      actor = users(role)
      assert_equal members.include?(role), actor.can?(:show, attachment), "#{role}: show"
      assert_equal role == :admin, actor.can?(:destroy, attachment), "#{role}: destroy"
    end
    [users(:server_admin), LoggedOutUser.new].each do |actor|
      assert_not actor.can?(:show, attachment)
      assert_not actor.can?(:destroy, attachment)
    end
  end
  test "subscription suspension prevents a non-instance coordinator from deleting a thread attachment" do
    coordinator = users(:member_normal)
    group = groups(:group)
    group.add_admin!(coordinator)
    assert_not coordinator.is_admin?
    record_id = topics(:discussion_topic).topicable_id
    assert coordinator.can?(:destroy, Attachment.new(record: Discussion.find(record_id)))

    group.update!(subscription: Subscription.create!(plan: 'free', state: 'on_hold'))
    attachment = Attachment.new(record: Discussion.find(record_id))
    assert coordinator.can?(:show, attachment)
    assert_not coordinator.can?(:destroy, attachment)
  end

  test "discarded groups prevent attachment deletion even for their coordinator" do
    coordinator = users(:admin)
    group = groups(:group)
    record_id = topics(:discussion_topic).topicable_id
    assert coordinator.can?(:destroy, Attachment.new(record: Discussion.find(record_id)))

    group.discard!
    assert_not coordinator.can?(:destroy, Attachment.new(record: Discussion.find(record_id)))
  end

end
