require 'test_helper'
require_relative '../support/access_volume_matrix'

class AttachmentPermissionServiceTest < ActiveSupport::TestCase
  setup do
    @topic = topics(:discussion_topic)
    @topic.update!(attachments_admin_only: true)
    @member = users(:member_normal)
    @admin = users(:admin)
    @blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new('supporting document'), filename: 'document.txt', content_type: 'text/plain'
    )
  end

  test 'restricted group and direct topics allow only their own admins to attach files' do
    %i[discussion_topic direct_topic public_discussion_topic].each do |name|
      topic = topics(name)
      topic.update!(attachments_admin_only: true)
      allowed_roles = case name
      when :discussion_topic then %i[admin guest_admin_normal]
      when :direct_topic then %i[guest_admin_normal]
      else []
      end
      (AccessVolumeMatrix::ROLES + [:server_admin]).each do |role|
        assert_equal allowed_roles.include?(role), users(role).can?(:attach_files, topic), "#{name}: #{role}"
      end
      assert_not LoggedOutUser.new.can?(:attach_files, topic)
    end
  end

  test 'unrestricted topics permit members and topic guests but do not grant access to outsiders' do
    @topic.update!(attachments_admin_only: false)
    %i[admin member_normal guest_normal guest_admin_normal].each do |role|
      assert users(role).can?(:attach_files, @topic), role.to_s
    end
    %i[alien former_guest_loud server_admin].each do |role|
      assert_not users(role).can?(:attach_files, @topic), role.to_s
    end
  end

  test 'suspended and discarded groups deny file additions to a thread admin' do
    actor = users(:guest_admin_normal)
    assert actor.can?(:attach_files, @topic)
    @topic.group.update!(subscription: Subscription.create!(plan: 'free', state: 'on_hold'))
    assert_not actor.can?(:attach_files, Topic.find(@topic.id))
    @topic.group.discard!
    assert_not @admin.can?(:attach_files, Topic.find(@topic.id))
  end

  test 'members cannot create comments with regular files or inline media' do
    [
      {files: [@blob]}, {image_files: [@blob]},
      {body: '<p>Reply</p><img src="https://example.com/text.png">', body_format: 'html'},
      {body: '![long reply](https://example.com/text.png)', body_format: 'md'},
      {body: '<video src="https://example.com/reply.mp4"></video>', body_format: 'html'}
    ].each do |attributes|
      comment = Comment.new({parent: @topic.topicable, body: 'Reply'}.merge(attributes))
      assert_no_difference ['Comment.count', 'TopicItem.count', 'ActiveStorage::Attachment.count'] do
        assert_raises CanCan::AccessDenied do
          CommentService.create(comment: comment, actor: @member)
        end
      end
    end
  end

  test 'group and thread admins can post files while members can still post text' do
    [@admin, users(:guest_admin_normal), @member].each do |actor|
      comment = Comment.new(parent: @topic.topicable, body: 'Reply')
      comment.files = [@blob] unless actor == @member
      CommentService.create(comment: comment, actor: actor)
      assert comment.persisted?, comment.errors.full_messages.join(', ')
      assert_equal actor == @member ? [] : [@blob.id], comment.reload.files.blobs.ids
    end
  end

  test 'text edits retain existing attachments and allow removal after restriction' do
    @topic.update!(attachments_admin_only: false)
    comment = Comment.new(parent: @topic.topicable, body: '![original](https://example.com/original.png)', body_format: 'md', files: [@blob])
    CommentService.create(comment: comment, actor: @member)
    @topic.update!(attachments_admin_only: true)

    CommentService.update(comment: comment.reload, actor: @member, params: {
      body: '<p>Edited</p><img src="https://example.com/original.png">', body_format: 'html', files: [@blob.signed_id]
    })
    assert_equal [@blob.id], comment.reload.files.blobs.ids
    assert_includes comment.body, 'Edited'

    CommentService.update(comment: comment, actor: @member, params: {body: 'Text only', files: []})
    assert_empty comment.reload.files
  end

  test 'new signed file ids and inline images are rejected before persisted comments attach anything' do
    comment = Comment.new(parent: @topic.topicable, body: 'Original')
    CommentService.create(comment: comment, actor: @member)
    url = Rails.application.routes.url_helpers.rails_blob_path(@blob, only_path: true)
    [{files: [@blob.signed_id]}, {image_files: [@blob.signed_id]}, {body: "![image](#{url})", body_format: 'md'}].each do |params|
      assert_no_difference 'ActiveStorage::Attachment.count' do
        assert_raises CanCan::AccessDenied do
          CommentService.update(comment: comment.reload, actor: @member, params: params)
        end
      end
      assert_equal 'Original', comment.reload.body
    end
  end

  test 'switching the format cannot activate media previously treated as plain text' do
    comment = Comment.new(parent: @topic.topicable, body: '<img src="https://example.com/reply.png"> Text', body_format: 'md')
    CommentService.create(comment: comment, actor: @member)
    assert comment.persisted?
    assert_raises CanCan::AccessDenied do
      CommentService.update(comment: comment, actor: @member, params: {body_format: 'html'})
    end
    assert_equal 'md', comment.reload.body_format
  end

  test 'a new topic author can supply context files and restrict later contributions' do
    discussion = DiscussionService.create(params: {
      title: 'Review', group_id: @topic.group_id, attachments_admin_only: true, files: [@blob]
    }, actor: @member)
    assert discussion.persisted?, discussion.errors.full_messages.join(', ')
    assert discussion.topic.attachments_admin_only?
    assert @member.can?(:attach_files, discussion.topic)
    assert_equal [@blob.id], discussion.reload.files.blobs.ids
  end

  test 'ordinary members cannot disable restrictions through a discussion edit' do
    assert @member.can?(:update, @topic.topicable)
    assert_raises CanCan::AccessDenied do
      DiscussionService.update(discussion: @topic.topicable, actor: @member, params: {
        attachments_admin_only: false, files: [@blob.signed_id]
      })
    end
    assert @topic.reload.attachments_admin_only?
    assert_empty @topic.topicable.files
  end

  test 'poll creation respects the existing thread restriction instead of template defaults' do
    assert_raises CanCan::AccessDenied do
      PollService.create(params: poll_params.merge(files: [@blob]), actor: @member)
    end
    poll = PollService.create(params: poll_params.merge(attachments_admin_only: false), actor: @member)
    assert poll.persisted?, poll.errors.full_messages.join(', ')
    assert poll.topic.attachments_admin_only?
    assert @topic.reload.attachments_admin_only?
  end

  test 'standalone polls carry the restriction into their own topic' do
    poll = PollService.create(params: poll_params.except(:topic_id).merge(
      group_id: @topic.group_id, attachments_admin_only: true, files: [@blob]
    ), actor: @member)
    assert poll.persisted?, poll.errors.full_messages.join(', ')
    assert poll.topic.attachments_admin_only?
    assert @member.can?(:attach_files, poll.topic)
  end

  test 'poll responses and outcomes use their containing topic restriction' do
    poll = PollService.create(params: poll_params, actor: @admin)
    stance = poll.stances.latest.find_by!(participant: @member)
    assert_raises CanCan::AccessDenied do
      StanceService.update(stance: stance, actor: @member, params: {reason: 'Reason', files: [@blob.signed_id]})
    end
    StanceService.update(stance: stance.reload, actor: @member, params: {reason: 'Reason',
      stance_choices_attributes: [{poll_option_id: poll.poll_options.first.id, score: 1}]})
    assert_equal 'Reason', stance.reload.reason
    assert_empty stance.files

    PollService.close(poll: poll, actor: @admin)
    outcome = Outcome.new(poll: poll, statement: 'Conclusion', files: [@blob])
    assert @member.can?(:create, outcome)
    assert_raises CanCan::AccessDenied do
      OutcomeService.create(outcome: outcome, actor: @member)
    end
    outcome = Outcome.new(poll: poll, statement: 'Conclusion')
    OutcomeService.create(outcome: outcome, actor: @member)
    assert outcome.persisted?
    assert_raises CanCan::AccessDenied do
      OutcomeService.update(outcome: outcome, actor: @member, params: {image_files: [@blob.signed_id]})
    end
    assert_empty outcome.reload.image_files
  end

  private

  def poll_params
    {topic_id: @topic.id, title: 'Proposal', poll_type: 'proposal', closing_at: 2.days.from_now, poll_option_names: ['Agree', 'Disagree']}
  end
end
