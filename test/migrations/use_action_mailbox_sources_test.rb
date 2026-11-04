require 'test_helper'
require_relative '../../db/migrate/20261021000003_use_action_mailbox_sources'

class UseActionMailboxSourcesTest < ActiveSupport::TestCase
  setup do
    @connection = ActiveRecord::Base.connection
    @schema = "inbound_migration_#{SecureRandom.hex(4)}"
    @previous_path = @connection.schema_search_path
    @connection.execute("CREATE SCHEMA #{@schema}")
    @connection.schema_search_path = "#{@schema}, public"
    @migration = UseActionMailboxSources.new
    @migration.suppress_messages do
      @migration.create_table(:action_mailbox_inbound_emails) do |t|
        t.string :message_id, null: false
        t.string :message_checksum, null: false
        t.integer :status, default: 0, null: false
        t.timestamps
      end
      @connection.execute("ALTER SEQUENCE #{@schema}.action_mailbox_inbound_emails_id_seq RESTART WITH 1000000")
      @migration.create_table(:received_emails) do |t|
        t.hstore :headers, default: {}, null: false
        t.string :message_id
        t.string :body_text
        t.string :body_html
        t.boolean :released, default: false
        t.integer :group_id
        t.timestamps
      end
    end
    ActionMailbox::InboundEmail.reset_column_information
    UseActionMailboxSources::LegacyEmail.reset_column_information
  end

  teardown do
    @connection.schema_search_path = @previous_path
    @connection.execute("DROP SCHEMA #{@schema} CASCADE")
    @connection.clear_cache!
    ActionMailbox::InboundEmail.reset_column_information
    PendingEmail.reset_column_information
  end

  test 'pending and blocked queues keep their identities and notifications with the original source' do
    inbound = build_inbound_email(headers: {from: 'unknown@example.test', to: 'forum@example.test'}, body_text: 'Original content')
    pending = legacy(message_id: inbound.message_id, group_id: groups(:group).id)
    blocked = legacy(message_id: 'blocked@example.test', group_id: nil)
    released = legacy(message_id: 'released@example.test', released: true)
    notification = legacy_notification(pending)
    obsolete = legacy_notification(released)

    @migration.suppress_messages { @migration.up }

    assert_equal inbound.id, PendingEmail.find(pending.id).inbound_email_id
    assert PendingEmail.find(blocked.id).blocked?
    assert_equal groups(:group).id, PendingEmail.find(blocked.id).group_id
    assert_equal 'PendingEmail', notification.reload.subject_type
    refute Notification.exists?(obsolete.id)
    refute @connection.table_exists?("#{@schema}.received_emails")
    assert_equal 'Original content', PendingEmail.find(pending.id).message.body_text
  end

  test 'an approval whose original source expired is rebuilt with its body and attachments' do
    pending = legacy(message_id: 'expired-source@example.test', group_id: groups(:group).id, body_text: 'Preserved approval')
    blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new('Preserved attachment'), filename: 'notes.txt')
    ActiveStorage::Attachment.insert_all!([{record_type: 'ReceivedEmail', record_id: pending.id, name: 'attachments', blob_id: blob.id, created_at: Time.current}])

    image = ActiveStorage::Blob.create_and_upload!(io: StringIO.new('Image content'), filename: 'image.png', content_type: 'image/png', identify: false)
    image_id = ActiveStorage::Attachment.insert_all!([{record_type: 'ReceivedEmail', record_id: pending.id, name: 'attachments', blob_id: image.id, created_at: Time.current}]).rows.first.first
    image_path = Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    pending.update!(body_html: "<p><img src=\"#{image_path}\"></p>")

    @migration.suppress_messages { @migration.up }

    source = PendingEmail.find(pending.id).inbound_email
    assert_equal 'expired-source@example.test', source.message_id
    assert_equal 'Preserved approval', source.mail.text_part.decoded
    assert_equal 'Preserved attachment', source.mail.attachments.first.decoded
    assert_equal 'notes.txt', source.mail.attachments.first.filename
    assert_equal 'image.png', source.mail.attachments.last.filename
    assert source.mail.attachments.last.inline?
    assert_includes source.mail.html_part.decoded, "cid:legacy-#{image_id}"
    assert_empty ActiveStorage::Attachment.where(record_type: 'ReceivedEmail')
  end

  test 'existing processed sources receive cleanup jobs at the new 60 day deadline' do
    inbound = build_inbound_email(headers: {from: 'member@example.test'}, body_text: 'Processed before upgrade')
    inbound.update_columns(status: :delivered, updated_at: 40.days.ago)
    previous = ActionMailbox.incinerate
    ActionMailbox.incinerate = true
    assert_enqueued_with(job: ActionMailbox::IncinerationJob, args: [inbound], at: ->(time) { time.between?(19.days.from_now, 21.days.from_now) }) do
      @migration.suppress_messages { @migration.up }
    end
  ensure
    ActionMailbox.incinerate = previous
  end

  private

  def legacy_notification(record)
    id = Notification.insert_all!([{kind: 'unknown_sender', subject_type: 'ReceivedEmail', subject_id: record.id,
      created_at: Time.current, updated_at: Time.current}]).rows.first.first
    Notification.find(id)
  end

  def legacy(**attributes)
    UseActionMailboxSources::LegacyEmail.create!({headers: {'From' => 'unknown@example.test', 'To' => "#{groups(:group).handle}@#{ENV.fetch('REPLY_HOSTNAME')}"},
      body_text: 'Original content'}.merge(attributes))
  end
end
