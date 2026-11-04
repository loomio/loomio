require 'test_helper'

class Api::V1::InboundEmailLifecycleTest < ActionController::TestCase
  tests Api::V1::PendingEmailsController

  setup do
    @group = groups(:group)
    @coordinator = users(:admin)
    sign_in @coordinator
  end

  test 'approving an unknown sender publishes the original body and attachments once' do
    mail = Mail.read_from_string(File.binread(Rails.root.join('spec/fixtures/files/email_with_mixed_attachments.eml')))
    mail.message_id = "#{SecureRandom.uuid}@approval.test"
    mail.from = 'Unknown Sender <unknown@approval.test>'
    mail.to = "#{@group.handle}@#{ENV.fetch('REPLY_HOSTNAME')}"
    inbound = receive(mail)
    pending = PendingEmail.find_by!(inbound_email: inbound)
    assert_equal @group, pending.group
    assert_equal 0, Discussion.where(title: pending.subject).count

    assert_difference 'Discussion.count', 1 do
      post :allow, params: {id: pending.id, user_id: @coordinator.id}
      assert_response :success
      inbound.route
    end
    discussion = Discussion.order(:id).last
    assert_equal @coordinator, discussion.author
    assert_equal @group, discussion.group
    assert_includes discussion.body, 'rails/active_storage/blobs/redirect/'
    refute_includes discussion.body, 'cid:'
    assert_equal %w[logo1.png logo2.png notes.txt], discussion.files.map { |file| file.filename.to_s }.sort
    assert_includes discussion.files.find { |file| file.filename.to_s == 'notes.txt' }.download, 'Some notes'
  end

  test 'scheduled cleanup holds pending messages and removes them after approval without another retention period' do
    previous = ActionMailbox.incinerate
    ActionMailbox.incinerate = true
    inbound = receive(build_mail)
    pending = PendingEmail.find_by!(inbound_email: inbound)

    travel 61.days
    perform_enqueued_jobs(only: ActionMailbox::IncinerationJob, at: Time.current)
    assert ActionMailbox::InboundEmail.exists?(inbound.id)
    assert_equal 'Please discuss this', inbound.reload.mail.body.decoded
    assert_enqueued_with(job: ActionMailbox::IncinerationJob, args: [inbound])

    travel 59.days
    sign_in @coordinator
    assert_no_enqueued_jobs only: ActionMailbox::IncinerationJob do
      post :allow, params: {id: pending.id, user_id: @coordinator.id}
      assert_response :success
    end
    refute PendingEmail.exists?(pending.id)

    travel 2.days
    perform_enqueued_jobs(only: ActionMailbox::IncinerationJob, at: Time.current)
    refute ActionMailbox::InboundEmail.exists?(inbound.id)
  ensure
    ActionMailbox.incinerate = previous
  end

  test 'scheduled cleanup holds blocked messages and handles queue deletion by a cascading foreign key' do
    previous = ActionMailbox.incinerate
    ActionMailbox.incinerate = true
    @group = Group.create!(name: 'Retained mail', handle: "retained-#{SecureRandom.hex(4)}")
    inbound = receive(build_mail)
    pending = PendingEmail.find_by!(inbound_email: inbound)
    pending.blocked!

    travel 61.days
    perform_enqueued_jobs(only: ActionMailbox::IncinerationJob, at: Time.current)
    assert ActionMailbox::InboundEmail.exists?(inbound.id)
    assert pending.reload.blocked?
    assert_enqueued_with(job: ActionMailbox::IncinerationJob, args: [inbound])

    Group.where(id: @group.id).delete_all
    refute PendingEmail.exists?(pending.id)
    travel 61.days
    perform_enqueued_jobs(only: ActionMailbox::IncinerationJob, at: Time.current)
    refute ActionMailbox::InboundEmail.exists?(inbound.id)
  ensure
    ActionMailbox.incinerate = previous
  end

  test 'a failed ordinary message can retry without losing content or creating duplicates' do
    mail = build_mail
    mail.from = @coordinator.email
    inbound = store(mail)
    DiscussionService.stub(:create, ->(**) { raise 'storage unavailable' }) do
      assert_raises(RuntimeError) { inbound.route }
    end
    assert inbound.reload.failed?
    assert_difference 'Discussion.count', 1 do
      inbound.route
      inbound.route
    end
    assert_equal 'Please discuss this', Discussion.order(:id).last.body
  end

  test 'completion marker failure rolls back both the discussion and its event before retry' do
    mail = build_mail
    mail.from = @coordinator.email
    inbound = store(mail)
    ActiveRecord::Base.connection.add_check_constraint(:action_mailbox_inbound_emails,
      "message_id != '#{inbound.message_id}' OR processing_completed_at IS NULL", name: 'test_inbound_completion_failure')
    assert_no_difference ['Discussion.count', 'TopicItem.count'] do
      assert_raises(ActiveRecord::StatementInvalid) { inbound.route }
    end
    assert inbound.reload.failed?
    assert_nil inbound.processing_completed_at
    ActiveRecord::Base.connection.remove_check_constraint(:action_mailbox_inbound_emails, name: 'test_inbound_completion_failure')
    assert_difference 'Discussion.count', 1 do
      inbound.route
    end
  end

  test 'failed approval preserves the original queued message and rolls back the alias' do
    inbound = receive(build_mail)
    pending = PendingEmail.find_by!(inbound_email: inbound)
    DiscussionService.stub(:create, ->(**) { raise 'storage unavailable' }) do
      assert_no_difference ['MemberEmailAlias.count', 'Discussion.count'] do
        assert_raises(RuntimeError) { post :allow, params: {id: pending.id, user_id: @coordinator.id} }
      end
    end
    assert PendingEmail.exists?(pending.id)
    assert_equal 'Please discuss this', pending.inbound_email.mail.body.decoded
    post :allow, params: {id: pending.id, user_id: @coordinator.id}
    assert_response :success
    refute PendingEmail.exists?(pending.id)
    inbound.update_columns(updated_at: 31.days.ago)
    inbound.reload.incinerate
    assert ActionMailbox::InboundEmail.exists?(inbound.id)
    inbound.update_columns(updated_at: 61.days.ago)
    inbound.reload.incinerate
    refute ActionMailbox::InboundEmail.exists?(inbound.id)
  end

  test 'an approval keeps its original destination when the old handle belongs to another group' do
    inbound = receive(build_mail)
    pending = PendingEmail.find_by!(inbound_email: inbound)
    old_handle = @group.handle
    @group.update!(handle: "renamed-#{SecureRandom.hex(4)}")
    GroupHandleRedirect.where(handle: old_handle).destroy_all
    other_group = groups(:alien_group)
    other_group.update!(handle: old_handle)

    assert_difference 'Discussion.count', 1 do
      post :allow, params: {id: pending.id, user_id: @coordinator.id}
      assert_response :success
    end
    assert_equal @group, Discussion.order(:id).last.group
    refute PendingEmail.exists?(pending.id)
  end

  test 'removing a sender block returns its retained message to the approval queue' do
    inbound = receive(build_mail)
    pending = PendingEmail.find_by!(inbound_email: inbound)
    post :block, params: {id: pending.id}
    assert_response :success
    assert pending.reload.blocked?
    assert_empty pending.notifications
    InboundEmailMessage.stub(:new, ->(*) { raise 'a retained sender block must not download MIME content' }) do
      InboundEmailService.retry_pending
    end
    alias_record = MemberEmailAlias.find_by!(group: @group, email: 'unknown@approval.test')
    delete :destroy_alias, params: {id: alias_record.id}
    assert_response :success
    assert pending.reload.pending?
    assert_equal @group, pending.group
    assert_equal 1, pending.notifications.count
    assert_equal 'Please discuss this', pending.message.body_text
  end

  test 'successful processing schedules one cleanup job for its source' do
    previous = ActionMailbox.incinerate
    ActionMailbox.incinerate = true
    mail = build_mail
    mail.from = @coordinator.email
    inbound = store(mail)
    assert_enqueued_jobs 1, only: ActionMailbox::IncinerationJob do
      inbound.route
    end
    assert inbound.reload.delivered?
  ensure
    ActionMailbox.incinerate = previous
  end

  private

  def build_mail
    Mail.new(from: 'unknown@approval.test', to: "#{@group.handle}@#{ENV.fetch('REPLY_HOSTNAME')}",
      subject: "Approval #{SecureRandom.hex(4)}", body: 'Please discuss this', message_id: "#{SecureRandom.uuid}@approval.test")
  end

  def store(mail)
    ActionMailbox::InboundEmail.create_and_extract_message_id!(mail.encoded, status: :processing)
  end

  def receive(mail)
    store(mail).tap(&:route)
  end
end
