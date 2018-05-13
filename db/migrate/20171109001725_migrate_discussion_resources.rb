class MigrateDiscussionResources < ActiveRecord::Migration[4.2]
  def change
    # MigrateAttachmentService.migrate!(attachments: Attachment.where(attachable_type: ["Poll", "Discussion"]))
  end
end
