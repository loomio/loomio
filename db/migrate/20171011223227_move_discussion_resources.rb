class MoveDiscussionResources < ActiveRecord::Migration
  def change
    add_column :attachments, :migrated_to_document, :boolean, default: false, null: false
  end
end
