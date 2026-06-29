class MarkDiscussionAsReadWorker < ApplicationJob
  def perform(discussion_id, sequence_id, user_id)
    TopicService.mark_as_read_simple_params(discussion_id, sequence_id, user_id)
  end
end
