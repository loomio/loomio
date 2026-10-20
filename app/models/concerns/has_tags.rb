module HasTags
  extend ActiveSupport::Concern

  included do
    before_validation :clean_tags
    after_save :ensure_tag_metadata, if: -> { saved_change_to_tags? || saved_change_to_group_id? }
    # A rolled-back merge or cleanup must not publish refresh jobs for those
    # uncommitted changes.
    after_save_commit :update_group_tags, if: -> { saved_change_to_tags? || saved_change_to_group_id? }
  end

  def tag_models
    group.parent_or_self.tags.where(name: self.tags).order(:name)
  end

  def ensure_tag_metadata
    # Removals must not recreate metadata during organization-wide deletion.
    added = saved_change_to_group_id? ? tags : tags - tags_before_last_save
    TagService.ensure_tag_metadata(group, added)
  end

  def update_group_tags
    return unless group_id
    UpdateGroupAndOrgTagsWorker.perform_later(self.group_id)
  end

  def clean_tags
    self.tags = TagService.clean_tag_names(tags)
  end
end
