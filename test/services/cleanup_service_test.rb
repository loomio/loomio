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
    user.update_columns(created_at: 3.years.ago, last_sign_in_at: 2.years.ago)
    user
  end

  test "audit identifies the exact new dangling reference after a deletion" do
    live = groups(:group)
    removed = Group.create!(name: "Tagged group", creator: @user, group_privacy: "secret")
    tag = tags(:cleanup_tag)
    Tagging.insert_all!([{tag_id: tag.id, taggable_type: "Group", taggable_id: live.id}])
    affected_id = Tagging.insert_all!([{tag_id: tag.id, taggable_type: "Group", taggable_id: removed.id}]).rows.first.first
    before = IntegrityAuditService.audit_orphan_records(include_ids: true)

    removed.destroy!

    after = IntegrityAuditService.audit_orphan_records(include_ids: true)
    assert_equal [affected_id], after[:missing_polymorphic_targets].fetch("Tagging.Group") - before[:missing_polymorphic_targets].fetch("Tagging.Group")
    assert Tagging.exists?(affected_id)
  end

  test "content blocks callbackless group deletion and survives cleanup" do
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

    assert_raises(ActiveRecord::InvalidForeignKey) do
      Group.transaction(requires_new: true) { Group.where(id: group.id).delete_all }
    end

    IntegrityAuditService.audit_orphan_records

    assert Membership.exists?(membership.id)
    assert Discussion.exists?(discussion.id)
    assert Topic.exists?(topic.id)
    assert Subscription.exists?(subscription.id)
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

    audit = IntegrityAuditService.audit_orphan_records

    assert_not_includes audit[:dangling_records], "Membership.missing_group"
    assert_equal 1, audit[:retained_records]["Subscription.missing_group"]
    assert_not Membership.exists?(membership.id)
    assert Subscription.exists?(subscription.id)
  end

  test "group deletion cascades pending approvals while preserving other sources" do
    group = groups(:group)
    removed_group = Group.create!(name: 'Removed group', creator: @user, group_privacy: 'secret')
    removed = create_pending_email(group: removed_group, headers: {from: 'unknown@example.test'})
    live = create_pending_email(group: group, headers: {from: 'unknown@example.test'})
    blocked = create_pending_email(group: group, headers: {from: 'blocked@example.test'})
    blocked.blocked!
    tag = Tag.create!(group: removed_group, name: "orphan #{@hex}")
    tagging_id = Tagging.insert_all!([{tag_id: tag.id, taggable_type: 'Group', taggable_id: group.id}]).rows.first.first

    removed_group.destroy!
    IntegrityAuditService.audit_orphan_records

    refute PendingEmail.exists?(removed.id)
    assert ActionMailbox::InboundEmail.exists?(removed.inbound_email_id)
    assert PendingEmail.exists?(live.id)
    assert PendingEmail.exists?(blocked.id)
    refute Tag.exists?(tag.id)
    refute Tagging.exists?(tagging_id)
    assert Group.exists?(group.id)
  end

  test "timeline content blocks callbackless topic deletion" do
    comment = comments(:public_discussion_comment)
    topic_item = topic_items(:public_discussion_comment_topic_item)
    assert_raises(ActiveRecord::InvalidForeignKey) do
      Topic.transaction(requires_new: true) { Topic.where(id: topic_item.topic_id).delete_all }
    end

    IntegrityAuditService.audit_orphan_records

    assert Comment.exists?(comment.id)
    assert TopicItem.exists?(topic_item.id)
  end

  test "the audit preserves a comment when only its timeline is missing" do
    comment = comments(:public_discussion_comment)
    comment.topic_items.delete_all

    IntegrityAuditService.audit_orphan_records

    assert Comment.exists?(comment.id)
  end

  test "the audit preserves a missing-root topic with surviving comments" do
    comment = comments(:public_discussion_comment)
    topic_id = comment.topic.id
    Discussion.where(id: comment.parent_id).delete_all

    IntegrityAuditService.audit_orphan_records

    assert Comment.exists?(comment.id)
    assert Topic.exists?(topic_id)
  end

  test "the audit preserves replies while their topic still exists" do
    comment = comments(:public_discussion_comment)
    reply = Comment.create!(parent: comment, user: @user, body: "Reply to orphan")
    Discussion.where(id: comment.parent_id).delete_all

    IntegrityAuditService.audit_orphan_records

    assert Comment.exists?(comment.id)
    assert Comment.exists?(reply.id)
  end

  test "the audit preserves comments which only lack a timeline entry" do
    comment = comments(:public_discussion_comment)
    comment.topic_items.destroy_all

    IntegrityAuditService.audit_orphan_records

    assert Comment.exists?(comment.id)
  end

  test "audit_orphan_records reports comments with missing parents separately" do
    comment = comments(:public_discussion_comment)
    Discussion.where(id: comment.parent_id).delete_all

    audit = IntegrityAuditService.audit_orphan_records

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

    audit = IntegrityAuditService.audit_orphan_records

    assert_equal 1, audit[:dangling_records]["Comment.missing_parent"]
    assert Comment.exists?(comment.id)
  end

  test "audit reports retained versions and unresolved models separately" do
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

    audit = IntegrityAuditService.audit_orphan_records(include_ids: true)

    assert_includes audit[:retained_records].fetch("PaperTrail::Version.Group"), orphan_version.id
    refute_includes audit[:retained_records].fetch("PaperTrail::Version.Group"), live_version.id
    assert_includes audit[:unresolved_polymorphic_types].fetch("PaperTrail::Version.Motion"), removed_model_version_id
    assert PaperTrail::Version.exists?(live_version.id)
    assert PaperTrail::Version.exists?(orphan_version.id)
    assert PaperTrail::Version.exists?(removed_model_version_id)
  end

  test "audit reports retired polymorphic types and preserves attachment links" do
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
    audit = IntegrityAuditService.audit_orphan_records

    assert_equal 1, audit[:retired_polymorphic_types]["ActiveStorage::Attachment.Document"]
    assert ActiveStorage::Attachment.exists?(attachment_id)
    assert ActiveStorage::Blob.exists?(blob.id)
  end

  test "destroy_inactive_orphan_users deletes long-inactive users with no durable references" do
    user = build_inactive_user
    PaperTrail::Version.create!(item_type: 'User', item_id: user.id, event: 'update')
    assert_includes RetentionService.inactive_orphan_user_ids, user.id

    transaction = ->(_tables, &cleanup_block) do
      ActiveRecord::Base.transaction(requires_new: true, &cleanup_block)
    end
    RetentionService.stub(:with_write_lock, transaction) do
      RetentionService.destroy_inactive_orphan_users
    end

    assert_not User.exists?(user.id)
    assert_not PaperTrail::Version.exists?(item_type: 'User', item_id: user.id)
  end

  test "inactive_orphan_user_ids excludes users who created groups" do
    user = build_inactive_user
    Group.create!(
      name: "Created Group #{@hex}",
      creator: user,
      group_privacy: 'secret'
    )

    assert_not_includes RetentionService.inactive_orphan_user_ids, user.id
  end
end
