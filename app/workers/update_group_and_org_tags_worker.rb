class UpdateGroupAndOrgTagsWorker < ApplicationJob
  retry_on ActiveRecord::Deadlocked, wait: :polynomially_longer, attempts: 5

  def perform(group_id)
    TagService.update_group_and_org_tags(group_id)
  end
end
