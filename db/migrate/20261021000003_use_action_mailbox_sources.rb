# Keep only actionable sender approvals; Action Mailbox owns message content,
# retries and retention. Older approvals may outlive their original source, so
# reconstruct that source once during the migration rather than keeping a second
# runtime representation of email content.
class UseActionMailboxSources < ActiveRecord::Migration[8.1]
  class LegacyEmail < ActiveRecord::Base
    self.table_name = 'received_emails'
  end

  def up
    add_column :action_mailbox_inbound_emails, :processing_completed_at, :datetime
    add_index :action_mailbox_inbound_emails, [:message_id, :id], name: 'index_inbound_emails_on_message_id_and_id'
    create_table :pending_emails do |t|
      t.references :group, null: false, foreign_key: {on_delete: :cascade}
      t.references :inbound_email, null: false, index: {unique: true},
        foreign_key: {to_table: :action_mailbox_inbound_emails}
      t.string :sender_email
      t.string :sender_name
      t.string :subject
      t.integer :status, null: false, default: 0
      t.timestamps
    end
    ActionMailbox::InboundEmail.reset_column_information
    PendingEmail.reset_column_information

    LegacyEmail.where(released: false).find_each do |legacy|
      inbound = ActionMailbox::InboundEmail.where(message_id: legacy.message_id).order(:id).first
      inbound ||= source_for(legacy)
      if EmailFeedbackService.feedback_sender?(InboundEmailMessage.new(inbound))
        inbound.update!(status: :failed)
        inbound.route_later
        next
      end
      group_id = legacy.group_id
      if group_id.nil?
        address = InboundEmailMessage.new(inbound).route_address
        handle = address&.split('@')&.first
        group_id = Group.find_by(handle: handle)&.id || GroupHandleRedirect.find_by(handle: handle)&.group_id if handle
      end
      unless group_id
        inbound.update!(status: :pending)
        inbound.route_later
        next
      end
      PendingEmail.create!(id: legacy.id, group_id: group_id, inbound_email: inbound,
        status: legacy.group_id ? :pending : :blocked,
        created_at: legacy.created_at, updated_at: legacy.updated_at)
      execute "UPDATE notifications SET subject_type = 'PendingEmail' WHERE subject_type = 'ReceivedEmail' AND subject_id = #{legacy.id.to_i}"
    end
    reset_pk_sequence!('pending_emails')
    execute <<~SQL
      UPDATE action_mailbox_inbound_emails SET processing_completed_at = updated_at
      WHERE status IN (2, 4)
    SQL
    # No remaining user action can reference these old notifications.
    Notification.where(subject_type: 'ReceivedEmail').find_each(&:destroy!)
    # Raw sources now contain the pending attachments. Leave blob deletion to
    # Active Storage so no shared attachment used by a thread is removed.
    ActiveStorage::Attachment.where(record_type: 'ReceivedEmail').find_in_batches do |attachments|
      ActiveStorage::Attachment.where(id: attachments.map(&:id)).delete_all
      ActiveStorage::Blob.where(id: attachments.map(&:blob_id)).find_each(&:purge_later)
    end
    drop_table :received_emails
    # Existing jobs may have been scheduled with Rails' old 30-day default.
    # Recheck each processed source at its new 60-day deadline as well.
    if ActionMailbox.incinerate
      ActionMailbox::InboundEmail.where(status: [:delivered, :failed, :bounced]).find_each do |inbound|
        deadline = [inbound.updated_at + ActionMailbox.incinerate_after, Time.current].max
        ActionMailbox::IncinerationJob.set(wait_until: deadline).perform_later(inbound)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Email content now belongs to Action Mailbox'
  end

  private

  def source_for(legacy)
    mail = Mail.new
    legacy.headers.each do |name, value|
      next if name.casecmp?('Content-Type') || name.casecmp?('Content-Transfer-Encoding') ||
        name.casecmp?('MIME-Version') || name.casecmp?('X-Loomio-Inbound-Email-Id')

      mail[name] = value
    end
    mail.message_id = legacy.message_id || "legacy-#{legacy.id}@loomio.local"
    attachments = ActiveStorage::Attachment.where(record_type: 'ReceivedEmail', record_id: legacy.id).includes(:blob)
    html = legacy.body_html&.dup
    attachments.each do |attachment|
      path = Rails.application.routes.url_helpers.rails_blob_path(attachment.blob, only_path: true)
      html&.gsub!(path, "cid:legacy-#{attachment.id}")
    end
    mail.text_part = Mail::Part.new(content_type: 'text/plain; charset=UTF-8', body: legacy.body_text.to_s)
    mail.html_part = Mail::Part.new(content_type: 'text/html; charset=UTF-8', body: html) if html.present?
    attachments.each do |attachment|
      list = html&.include?("cid:legacy-#{attachment.id}") ? mail.attachments.inline : mail.attachments
      list[attachment.filename.to_s] = {mime_type: attachment.content_type, content: attachment.download}
      mail.attachments.last.content_id = "legacy-#{attachment.id}"
    end
    ActionMailbox::InboundEmail.create_and_extract_message_id!(mail.encoded, status: :delivered)
  end

  def reset_pk_sequence!(table)
    connection.reset_pk_sequence!(table)
  end
end
