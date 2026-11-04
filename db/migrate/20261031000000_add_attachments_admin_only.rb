class AddAttachmentsAdminOnly < ActiveRecord::Migration[8.1]
  def change
    add_column :topics, :attachments_admin_only, :boolean, default: false, null: false
    add_column :discussion_templates, :attachments_admin_only, :boolean, default: false, null: false
    add_column :poll_templates, :attachments_admin_only, :boolean, default: false, null: false
  end
end
