class UpdateGroupAndOrgTagsWorker < ApplicationJob
  def perform(group_id)
    TagService.update_group_and_org_tags(group_id)
  end
end
