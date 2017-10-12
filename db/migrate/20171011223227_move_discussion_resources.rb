class MoveDiscussionResources < ActiveRecord::Migration
  def change
    add_column :attachments, :migrated_to_document, :boolean, default: false, null: false
    MigrateAttachmentService.migrate!(attachments: Attachment.where(attachable_type: "Discussion"))
  end
end
