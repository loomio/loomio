class MigrateDiscussionResources < ActiveRecord::Migration
  def change
    MigrateAttachmentService.migrate!(attachments: Attachment.where(attachable_type: ["Poll", "Discussion"]))
  end
end
