class MarkDigestAsReadWorker < ApplicationJob
  def perform(user_id, time_start, time_finish)
    DigestService.mark_as_read(
      user_id: user_id,
      time_start_i: time_start,
      time_finish_i: time_finish
    )
  end
end
