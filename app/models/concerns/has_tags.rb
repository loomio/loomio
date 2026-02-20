module HasTags
  extend ActiveSupport::Concern

  included do
    after_save :update_group_tags
  end

  def tag_models
    topic.group.tags.where(name: self.tags).order(:priority)
  end

  def update_group_tags
    return unless self.topic.group_id
    GenericWorker.perform_async('TagService', 'update_group_and_org_tags', self.topic.group_id)
  end
end
