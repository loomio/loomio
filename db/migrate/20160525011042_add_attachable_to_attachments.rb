class AddAttachableToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :attachable_id, :integer
    add_column :attachments, :attachable_type, :string
  end
end
