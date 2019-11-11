class ChangeAttachmentsDefaultToArray < ActiveRecord::Migration[5.2]
  def change
    change_column :discussions, :attachments, :jsonb, null: false, default: []
    change_column :groups, :attachments, :jsonb, null: false, default: []
    change_column :outcomes, :attachments, :jsonb, null: false, default: []
    change_column :comments, :attachments, :jsonb, null: false, default: []
    change_column :stances, :attachments, :jsonb, null: false, default: []
    change_column :polls, :attachments, :jsonb, null: false, default: []
    change_column :users, :attachments, :jsonb, null: false, default: []
  end
end
