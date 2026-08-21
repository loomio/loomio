require 'test_helper'

class CleanupServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @hex = SecureRandom.hex(4)
  end

  def build_inactive_user
    user = User.create!(
      name: "orphan #{@hex}",
      email: "orphan-#{@hex}@example.com",
      username: "orphan#{@hex}",
      email_verified: true
    )
    user.update_column(:last_sign_in_at, 2.years.ago)
    user
  end

  test "delete_orphan_records removes records dangling from hard-deleted groups" do
    subscription = Subscription.create!(plan: 'demo')
    group = Group.create!(
      name: "Dangling Cleanup #{SecureRandom.hex(4)}",
      creator: @user,
      group_privacy: 'secret',
      subscription: subscription
    )
    membership = group.add_member!(@user)
    discussion = DiscussionService.create(
      params: { group_id: group.id, title: "Dangling discussion" },
      actor: @user
    )
    topic = discussion.topic

    Group.where(id: group.id).delete_all

    CleanupService.delete_orphan_records

    assert_not Membership.exists?(membership.id)
    assert_not Discussion.exists?(discussion.id)
    assert_not Topic.exists?(topic.id)
    assert_not Subscription.exists?(subscription.id)
  end

  test "audit_orphan_records reports candidates without deleting them" do
    subscription = Subscription.create!(plan: 'demo')
    group = Group.create!(
      name: "Dangling Audit #{SecureRandom.hex(4)}",
      creator: @user,
      group_privacy: 'secret',
      subscription: subscription
    )
    membership = group.add_member!(@user)

    Group.where(id: group.id).delete_all

    audit = CleanupService.audit_orphan_records

    assert_equal 1, audit[:dangling_records]["Membership.missing_group"]
    assert_equal 1, audit[:dangling_records]["Subscription.missing_group"]
    assert Membership.exists?(membership.id)
    assert Subscription.exists?(subscription.id)
  end

  test "delete_orphan_records deletes comments whose event topic is missing" do
    comment = comments(:public_discussion_comment)
    event = events(:public_discussion_comment_event)
    Topic.where(id: event.topic_id).delete_all

    CleanupService.delete_orphan_records

    assert_not Comment.exists?(comment.id)
    assert_not Event.exists?(event.id)
  end

  test "delete_orphan_records deletes a comment when its event is missing" do
    comment = comments(:public_discussion_comment)
    comment.events.delete_all

    CleanupService.delete_orphan_records

    assert_not Comment.exists?(comment.id)
  end

  test "delete_orphan_records deletes missing-parent comment forests" do
    comment = comments(:public_discussion_comment)
    Discussion.where(id: comment.parent_id).delete_all

    CleanupService.delete_orphan_records

    assert_not Comment.exists?(comment.id)
  end

  test "cleanup_comment_references deletes each layer of a missing-parent comment forest" do
    comment = comments(:public_discussion_comment)
    reply = Comment.create!(parent: comment, user: @user, body: "Reply to orphan")
    Discussion.where(id: comment.parent_id).delete_all

    CleanupService.cleanup_comment_references!

    assert_not Comment.exists?(comment.id)
    assert_not Comment.exists?(reply.id)
  end

  test "cleanup_comment_references deletes comments which have no timeline event" do
    comment = comments(:public_discussion_comment)
    comment.events.destroy_all

    CleanupService.cleanup_comment_references!

    assert_not Comment.exists?(comment.id)
  end

  test "audit_orphan_records reports comments with missing parents separately" do
    comment = comments(:public_discussion_comment)
    Discussion.where(id: comment.parent_id).delete_all

    audit = CleanupService.audit_orphan_records

    assert_equal 1, audit[:dangling_records]["Comment.missing_parent"]
    assert_equal 0, audit[:dangling_records]["Comment.missing_event"]
    assert Comment.exists?(comment.id)
  end

  test "audit_orphan_records recognizes a missing stance parent" do
    poll = PollService.create(
      params: {
        poll_type: "poll",
        title: "Stance parent cleanup",
        poll_option_names: %w[Yes No],
        closing_at: 1.day.from_now,
        group_id: groups(:group).id,
        notify_on_open: false
      },
      actor: @user
    )
    stance = poll.stances.find_by!(participant: @user)
    comment = Comment.create!(parent: stance, user: @user, body: "Stance reply")
    Stance.where(id: stance.id).delete_all

    audit = CleanupService.audit_orphan_records

    assert_equal 1, audit[:dangling_records]["Comment.missing_parent"]
    assert Comment.exists?(comment.id)
  end

  test "delete_orphan_versions removes PaperTrail versions for missing records" do
    group = Group.create!(
      name: "Version Cleanup #{SecureRandom.hex(4)}",
      creator: @user,
      group_privacy: 'secret'
    )
    live_version = PaperTrail::Version.create!(item_type: 'Group', item_id: group.id, event: 'update')
    orphan_version = PaperTrail::Version.create!(item_type: 'Group', item_id: Group.maximum(:id) + 100, event: 'update')
    removed_model_version_id = PaperTrail::Version.insert_all!(
      [ { item_type: 'Motion', item_id: 1, event: 'update', created_at: Time.current } ],
      returning: %w[id]
    ).rows.first.first

    CleanupService.delete_orphan_versions

    assert PaperTrail::Version.exists?(live_version.id)
    assert_not PaperTrail::Version.exists?(orphan_version.id)
    assert_not PaperTrail::Version.exists?(removed_model_version_id)
  end

  test "delete_orphan_records deletes references to retired polymorphic types" do
    blob = ActiveStorage::Blob.create!(
      key: "retired-document-#{@hex}",
      filename: "retired.txt",
      service_name: ActiveStorage::Blob.service.name,
      byte_size: 0,
      checksum: "1B2M2Y8AsgTpgAmY7PhCfg==",
      created_at: Time.current
    )
    attachment_id = ActiveStorage::Attachment.insert_all!([ {
      blob_id: blob.id,
      created_at: Time.current,
      name: "file",
      record_id: 1,
      record_type: "Document"
    } ], returning: %w[id]).rows.first.first
    event_ids = Event.insert_all!([
      { eventable_id: 1, eventable_type: "GroupIdentity", kind: "legacy", created_at: Time.current, updated_at: Time.current },
      { eventable_id: 1, eventable_type: "Invitation", kind: "legacy", created_at: Time.current, updated_at: Time.current }
    ], returning: %w[id]).rows.flatten

    audit = CleanupService.audit_orphan_records

    assert_equal 1, audit[:retired_polymorphic_types]["ActiveStorage::Attachment.Document"]
    assert_equal 1, audit[:retired_polymorphic_types]["Event.GroupIdentity"]
    assert_equal 1, audit[:retired_polymorphic_types]["Event.Invitation"]

    CleanupService.delete_orphan_records

    assert_not ActiveStorage::Attachment.exists?(attachment_id)
    assert_not Event.exists?(id: event_ids)
    assert ActiveStorage::Blob.exists?(blob.id)
  end

  test "destroy_orphan_users deletes long-inactive users with no durable references" do
    user = build_inactive_user
    PaperTrail::Version.create!(item_type: 'User', item_id: user.id, event: 'update')

    InactiveUserCleanupService.destroy_orphan_users

    assert_not User.exists?(user.id)
    assert_not PaperTrail::Version.exists?(item_type: 'User', item_id: user.id)
  end

  test "orphan_user_ids excludes users who created groups" do
    user = build_inactive_user
    Group.create!(
      name: "Created Group #{@hex}",
      creator: user,
      group_privacy: 'secret'
    )

    assert_not_includes InactiveUserCleanupService.orphan_user_ids, user.id
  end
end
