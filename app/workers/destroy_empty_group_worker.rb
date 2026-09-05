class DestroyEmptyGroupWorker < ApplicationJob
  queue_as :low

  def perform(group_id)
    EmptyGroupCleanupService.destroy_if_empty!(group_id)
  end
end
