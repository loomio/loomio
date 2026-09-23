class EnqueueInlineImageAttachmentRepair < ActiveRecord::Migration[8.0]
  def up
    RepairInlineImageAttachmentsWorker
      .set(wait: 15.minutes)
      .perform_later
  end

  def down
  end
end
