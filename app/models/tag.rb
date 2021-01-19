class Tag < ApplicationRecord
  include CustomCounterCache::Model
  belongs_to :group
  has_many :discussion_tags, dependent: :destroy
  has_many :discussions, through: :discussion_tags

  validates :group, presence: true
  validates :name, presence: true
  validates :color, presence: true, format: /\A#([A-F0-9]{3}){1,2}\z/i

  define_counter_cache(:discussion_tags_count) { |tag| tag.kept_discussion_tags_count }

  def kept_discussion_tags_count
    discussion_tags.joins(:discussion).where('discussions.discarded_at is null').count
  end
end
