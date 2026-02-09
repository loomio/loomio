module ResetDatabaseHelper
  module_function

  def reset_database
    tables = %w[
      stance_receipts omniauth_identities users groups memberships polls outcomes
      events discussions stances stance_choices poll_options tasks
      discussion_readers discussion_templates poll_templates
      action_mailbox_inbound_emails
      active_storage_attachments
      active_storage_blobs
      active_storage_variant_records
      attachments
      chatbots
      comments
      documents
      login_tokens
      member_email_aliases
      membership_requests
      notifications
      oauth_access_grants
      oauth_access_tokens
      partition_sequences
      pg_search_documents
      reactions
      received_emails
      taggings
      tags
      tasks
      tasks_users
      translations
      versions
      webhooks
    ]
    conn = ActiveRecord::Base.connection
    conn.execute("SET session_replication_role = 'replica'")
    tables.each { |t| conn.execute("DELETE FROM #{t}") }
    conn.execute("SET session_replication_role = 'origin'")
  end
end
