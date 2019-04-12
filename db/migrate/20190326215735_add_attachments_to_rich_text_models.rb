class AddAttachmentsToRichTextModels < ActiveRecord::Migration[5.2]
  def change
    add_column :discussions, :attachments, :jsonb, default: {}, null: false
    add_column :groups, :attachments, :jsonb, default: {}, null: false
    add_column :outcomes, :attachments, :jsonb, default: {}, null: false
    add_column :polls, :attachments, :jsonb, default: {}, null: false
    add_column :stances, :attachments, :jsonb, default: {}, null: false
    add_column :users, :attachments, :jsonb, default: {}, null: false
  end
end
