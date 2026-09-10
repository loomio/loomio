class DiscardGroupWorker < ApplicationJob
  queue_as :low

  def perform(group_id)
    return unless ENV["CLEANUP_ENABLED"].present?

    group = Group.kept.find_by(id: group_id)
    GroupService.discard(group: group) if group
  end
end
