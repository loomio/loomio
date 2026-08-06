class RepairInlineImageAttachmentsWorker < ApplicationJob
  queue_as :low

  def perform
    stats = InlineImageAttachmentRepairService.run(
      dry_run: false,
      progress: ->(message) { Rails.logger.info(message) }
    )
    Rails.logger.info("Inline image attachment repair complete: #{stats.to_json}")
  end
end
