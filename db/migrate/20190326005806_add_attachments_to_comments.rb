class AddAttachmentsToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :attachments, :jsonb, null: false, default: {}
  end
end
