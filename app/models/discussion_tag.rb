class DiscussionTag < ActiveRecord::Base
  include CustomCounterCache::Model
  belongs_to :discussion
  belongs_to :tag
  has_one :group, through: :discussion
  delegate :group_id, to: :discussion

  validates :discussion, presence: true
  validates :tag, presence: true

  update_counter_cache :tag, :discussion_tags_count
end
