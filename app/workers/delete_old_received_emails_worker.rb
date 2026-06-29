class DeleteOldReceivedEmailsWorker < ApplicationJob
  def perform
    ReceivedEmailService.delete_old_emails
  end
end
