class MigrateCommentDocuments < ActiveRecord::Migration
  def change
    MigrateAttachmentService.migrate! attachments: Attachment.all
  end
end
