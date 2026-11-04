class RetryPendingEmailsWorker < ApplicationJob
  def perform
    InboundEmailService.retry_pending
  end
end
