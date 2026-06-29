class PollGroupMembersAddedWorker < ApplicationJob
  def perform(group_id)
    PollService.group_members_added(group_id)
  end
end
