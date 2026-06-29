class UpdateDescendantHandlesWorker < ApplicationJob
  def perform(group_id, old_handle, new_handle)
    GroupService.update_descendant_handles(group_id, old_handle, new_handle)
  end
end
