class PollGroupMembersAddedWorker < ApplicationJob
  retry_on ActiveRecord::Deadlocked, wait: :polynomially_longer, attempts: 5

  def perform(group_id)
    PollService.group_members_added(group_id)
  end
end
