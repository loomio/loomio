class MarkSummaryEmailAsReadWorker < ApplicationJob
  def perform(user_id, time_start, time_finish)
    TopicService.mark_summary_email_as_read(user_id, time_start, time_finish)
  end
end
