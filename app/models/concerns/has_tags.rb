module HasTags
  extend ActiveSupport::Concern

  included do
    has_many :taggings, dependent: :destroy, as: :taggable
    has_many :tags, through: :taggings
    before_save :filter_tags_by_group
  end
  
  def filter_tags_by_group
    self.tag_ids = Tag.where(group_id: group.parent_or_self.id, id: tag_ids).pluck(:id)
  end
end
