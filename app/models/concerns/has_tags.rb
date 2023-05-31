module HasTags
  extend ActiveSupport::Concern

  included do
    after_save :update_group_tags
  end
  
  def update_group_tags
    GenericWorker.perform_async('TagService', 'update_group_tags', self.group_id)
    GenericWorker.perform_async('TagService', 'update_org_tagging_counts', self.group_id)
  end
end
