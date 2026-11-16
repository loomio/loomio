require 'test_helper'

class DestroyUserWorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @spammer = User.create!(name: 'Spam sender', email: "spam-sender-#{SecureRandom.hex(4)}@example.com", email_verified: true)
    @group = Group.create!(name: 'Spam group', creator: @spammer, group_privacy: 'secret')
    @group.add_admin!(@spammer)
    @thread = DiscussionService.create(params: { title: 'Spam direct thread' }, actor: @spammer)
    @blobs = []
  end

  teardown do
    @blobs.each { |blob| blob.service.delete(blob.key) }
  end

  test 'queued account deletion purges a direct thread file and invalidates its download identifier' do
    blob = attach_file(@thread)
    signed_id = blob.signed_id

    perform_enqueued_jobs(only: [ DestroyUserWorker, ActiveStorage::PurgeJob ]) do
      DestroyUserWorker.perform_later(@spammer.id)
    end

    assert_not User.exists?(@spammer.id)
    assert_not Group.exists?(@group.id)
    assert_not Discussion.exists?(@thread.id)
    assert_not Topic.exists?(@thread.topic_id)
    assert_not ActiveStorage::Blob.exists?(blob.id)
    assert_not blob.service.exist?(blob.key)
    assert_nil ActiveStorage::Blob.find_signed(signed_id)
  end

  test 'account deletion includes files from cascaded groups threads comments and polls' do
    group_thread = DiscussionService.create(params: { title: 'Group thread', group_id: @group.id }, actor: @spammer)
    @group.add_member!(users(:member_normal))
    comment = Comment.new(parent: group_thread, body: 'Reply with a file')
    CommentService.create(comment: comment, actor: users(:member_normal))
    poll = PollService.create(params: { title: 'Standalone poll', group_id: @group.id, poll_type: 'proposal',
      poll_option_names: [ 'Agree' ], closing_at: 2.days.from_now }, actor: @spammer)
    blobs = [ attach_file(@group), attach_file(@group, name: 'logo'), attach_file(@group, name: 'cover_photo'), attach_file(group_thread, name: 'image_files'),
      attach_file(comment), attach_file(poll), attach_file(@spammer, name: 'image_files') ]

    DestroyUserWorker.perform_now(@spammer.id)
    perform_enqueued_jobs(only: ActiveStorage::PurgeJob)

    assert_not Comment.exists?(comment.id)
    assert_not Poll.exists?(poll.id)
    blobs.each do |blob|
      assert_not ActiveStorage::Blob.exists?(blob.id), "blob #{blob.id} was retained"
      assert_not blob.service.exist?(blob.key)
    end
  end

  test 'files shared with surviving content remain available' do
    blob = attach_file(@thread)
    surviving_thread = discussions(:discussion)
    surviving_thread.files.attach(blob)
    clear_enqueued_jobs

    DestroyUserWorker.perform_now(@spammer.id)
    perform_enqueued_jobs(only: ActiveStorage::PurgeJob)

    assert Discussion.exists?(surviving_thread.id)
    assert surviving_thread.reload.files.blobs.exists?(blob.id)
    assert ActiveStorage::Blob.exists?(blob.id)
    assert blob.service.exist?(blob.key)
  end

  test 'hard deleting a thread purges its files without deleting its author' do
    blob = attach_file(@thread)

    @thread.topic.destroy!
    perform_enqueued_jobs(only: ActiveStorage::PurgeJob)

    assert User.exists?(@spammer.id)
    assert_not Discussion.exists?(@thread.id)
    assert_not ActiveStorage::Blob.exists?(blob.id)
    assert_not blob.service.exist?(blob.key)
  end

  test 'discarding groups and threads retains files without scheduling purges' do
    thread_blob = attach_file(@thread)
    group_blob = attach_file(@group)
    clear_enqueued_jobs

    @group.discard!(actor: @spammer)
    TopicService.discard_without_authorization(topic: @thread.topic, actor: @spammer)

    assert_no_enqueued_jobs(only: ActiveStorage::PurgeJob)
    [ thread_blob, group_blob ].each do |blob|
      assert ActiveStorage::Blob.exists?(blob.id)
      assert blob.service.exist?(blob.key)
      assert blob.attachments.exists?
    end
  end

  test 'purge jobs wait until the surrounding transaction commits' do
    blob = attach_file(@thread)
    clear_enqueued_jobs

    User.transaction do
      DestroyUserWorker.perform_now(@spammer.id)
      assert_no_enqueued_jobs(only: ActiveStorage::PurgeJob)
      assert blob.service.exist?(blob.key)
    end

    assert_enqueued_with(job: ActiveStorage::PurgeJob, args: [ blob ])
    perform_enqueued_jobs(only: ActiveStorage::PurgeJob)
    assert_not ActiveStorage::Blob.exists?(blob.id)
    assert_not blob.service.exist?(blob.key)
  end

  test 'rolling back account deletion preserves files and does not enqueue purges' do
    blob = attach_file(@thread)
    clear_enqueued_jobs

    User.transaction do
      DestroyUserWorker.perform_now(@spammer.id)
      raise ActiveRecord::Rollback
    end

    assert User.exists?(@spammer.id)
    assert Discussion.exists?(@thread.id)
    assert @thread.reload.files.attached?
    assert ActiveStorage::Blob.exists?(blob.id)
    assert blob.service.exist?(blob.key)
    assert_no_enqueued_jobs(only: ActiveStorage::PurgeJob)
  end

  test 'hard deleting a thread removes nested replies and their files' do
    parent = Comment.new(parent: @thread, body: 'Parent reply')
    CommentService.create(comment: parent, actor: @spammer)
    reply = Comment.new(parent: parent, body: 'Nested reply')
    CommentService.create(comment: reply, actor: @spammer)
    blobs = [ attach_file(parent), attach_file(reply) ]

    @thread.topic.destroy!
    perform_enqueued_jobs(only: ActiveStorage::PurgeJob)

    assert_not Comment.exists?(parent.id)
    assert_not Comment.exists?(reply.id)
    blobs.each do |blob|
      assert_not ActiveStorage::Blob.exists?(blob.id)
      assert_not blob.service.exist?(blob.key)
    end
  end

  test 'comment deletion with replies is denied and preserves their files' do
    parent = Comment.new(parent: @thread, body: 'Parent reply')
    CommentService.create(comment: parent, actor: @spammer)
    reply = Comment.new(parent: parent, body: 'Nested reply')
    CommentService.create(comment: reply, actor: @spammer)
    deleted_blob = attach_file(parent)
    retained_blob = attach_file(reply)

    clear_enqueued_jobs

    assert_no_enqueued_jobs(only: ActiveStorage::PurgeJob) do
      assert_raises(CanCan::AccessDenied) { CommentService.destroy(comment: parent, actor: @spammer) }
    end

    assert Comment.exists?(parent.id)
    assert_equal parent, reply.reload.parent
    [ deleted_blob, retained_blob ].each do |blob|
      assert ActiveStorage::Blob.exists?(blob.id)
      assert blob.service.exist?(blob.key)
    end
  end

  private

  def attach_file(record, name: 'files')
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new('Account deletion test file'), filename: "delete-#{SecureRandom.hex(4)}.pdf",
      content_type: 'application/pdf', identify: false, metadata: { identified: true, analyzed: true }
    )
    @blobs << blob
    record.public_send(name).attach(blob)
    blob
  end
end
