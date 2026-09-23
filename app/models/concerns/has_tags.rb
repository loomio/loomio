module HasTags
  extend ActiveSupport::Concern

  included do
    before_validation :clean_tags
    # Counter updates also save tagged records. A rolled-back merge or cleanup
    # must not publish refresh jobs for those uncommitted changes.
    after_save_commit :update_group_tags
  end

  def tag_models
    group.parent_or_self.tags.where(name: self.tags).order(:name)
  end

  def update_group_tags
    return unless group_id
    UpdateGroupAndOrgTagsWorker.perform_later(self.group_id)
  end

  def clean_tags
    self.tags = TagService.clean_tag_names(tags)
  end
end
