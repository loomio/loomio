class MoveDiscussionResources < ActiveRecord::Migration[4.2]
  def change
    add_column :attachments, :migrated_to_document, :boolean, default: false, null: false
  end
end
