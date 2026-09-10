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

  test "delete_records limits one integrity category batch" do
    missing_tag_id = Tag.maximum(:id) + 1
    now = Time.current
    Tagging.insert_all!(Array.new(CleanupService::DELETE_BATCH_SIZE + 1) do |index|
      {
        tag_id: missing_tag_id,
        taggable_type: "Group",
        taggable_id: Group.maximum(:id) + index + 1,
        created_at: now,
        updated_at: now
      }
    end)

    assert_equal CleanupService::DELETE_BATCH_SIZE,
                 CleanupService.delete_records(CleanupService.taggings_missing_tag)
    assert_equal 1, CleanupService.taggings_missing_tag.count
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

    assert_not_includes audit[:dangling_records], "Membership.missing_group"
    assert_equal 1, audit[:dangling_records]["Subscription.missing_group"]
    assert_not Membership.exists?(membership.id)
    assert Subscription.exists?(subscription.id)
  end

  test "orphan cleanup removes group metadata and dependent references but preserves live and unassigned records" do
    group = groups(:group)
    missing_group_id = Group.maximum(:id) + 1
    models = [GroupSurvey, ReceivedEmail, CleanupService::LegacyWebhook, Tag]
    records = models.map do |model|
      attributes = { group_id: missing_group_id }
      attributes[:name] = "orphan #{@hex}" if [Tag, CleanupService::LegacyWebhook].include?(model)
      orphan = model.find(model.insert_all!([attributes]).rows.first.first)
      live = model.create!(attributes.merge(group_id: group.id))
      [orphan, live]
    end
    unassigned_email = ReceivedEmail.create!
    email = records[1].first
    tag = records[3].first
    tagging_id = Tagging.insert_all!([{ tag_id: tag.id, taggable_type: 'Group', taggable_id: group.id }]).rows.first.first
    blob = ActiveStorage::Blob.create!(key: "orphan-email-#{@hex}", filename: 'message.txt', byte_size: 0, checksum: 'empty', service_name: ActiveStorage::Blob.service.name)
    attachment_id = ActiveStorage::Attachment.insert_all!([{ name: 'attachments', record_type: 'ReceivedEmail', record_id: email.id, blob_id: blob.id, created_at: Time.current }]).rows.first.first

    audit = CleanupService.audit_orphan_records
    %w[GroupSurvey ReceivedEmail Webhook Tag].each do |name|
      assert_equal 1, audit[:dangling_records]["#{name}.missing_group"]
    end
    records.each { |orphan, _| assert orphan.class.exists?(orphan.id) }

    CleanupService.delete_orphan_records

    records.each do |orphan, live|
      assert_not orphan.class.exists?(orphan.id)
      assert live.class.exists?(live.id)
    end
    assert ReceivedEmail.exists?(unassigned_email.id)
    assert_not Tagging.exists?(tagging_id)
    assert_not ActiveStorage::Attachment.exists?(attachment_id)
    assert ActiveStorage::Blob.exists?(blob.id)
    assert Group.exists?(group.id)
  end

  test "delete_orphan_records preserves content with a live parent when its topic is missing" do
    comment = comments(:public_discussion_comment)
    topic_item = topic_items(:public_discussion_comment_topic_item)
    Topic.where(id: topic_item.topic_id).delete_all

    CleanupService.delete_orphan_records

    assert Comment.exists?(comment.id)
    assert_not TopicItem.exists?(topic_item.id)
  end

  test "delete_orphan_records preserves a comment when only its timeline is missing" do
    comment = comments(:public_discussion_comment)
    comment.topic_items.delete_all

    CleanupService.delete_orphan_records

    assert Comment.exists?(comment.id)
  end

  test "delete_orphan_records deletes missing-parent comment forests" do
    comment = comments(:public_discussion_comment)
    Discussion.where(id: comment.parent_id).delete_all

    CleanupService.delete_orphan_records

    assert_not Comment.exists?(comment.id)
  end

  test "cleanup_comment_references preserves replies while their topic still exists" do
    comment = comments(:public_discussion_comment)
    reply = Comment.create!(parent: comment, user: @user, body: "Reply to orphan")
    Discussion.where(id: comment.parent_id).delete_all

    CleanupService.cleanup_comment_references!

    assert Comment.exists?(comment.id)
    assert Comment.exists?(reply.id)
  end

  test "cleanup_comment_references preserves comments which only lack a timeline entry" do
    comment = comments(:public_discussion_comment)
    comment.topic_items.destroy_all

    CleanupService.cleanup_comment_references!

    assert Comment.exists?(comment.id)
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
    audit = CleanupService.audit_orphan_records

    assert_equal 1, audit[:retired_polymorphic_types]["ActiveStorage::Attachment.Document"]
    CleanupService.delete_orphan_records

    assert_not ActiveStorage::Attachment.exists?(attachment_id)
    assert ActiveStorage::Blob.exists?(blob.id)
  end

  test "delete_inactive_orphan_users deletes long-inactive users with no durable references" do
    user = build_inactive_user
    PaperTrail::Version.create!(item_type: 'User', item_id: user.id, event: 'update')
    assert_includes CleanupService.inactive_orphan_user_ids, user.id

    transaction = ->(_tables, &cleanup_block) do
      ActiveRecord::Base.transaction(requires_new: true, &cleanup_block)
    end
    CleanupService.stub(:with_write_lock, transaction) do
      CleanupService.delete_inactive_orphan_users
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

    assert_not_includes CleanupService.inactive_orphan_user_ids, user.id
  end
end
