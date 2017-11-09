class MigrateDiscussionResources < ActiveRecord::Migration
  def change
    MigrateAttachmentService.migrate!(attachments: Attachment.where(attachable_type: "Discussion"))
  end
end
