class Tag < ApplicationRecord
  include CustomCounterCache::Model
  include Translatable
  is_translatable on: :name
  
  belongs_to :group
  has_many :taggings, dependent: :destroy
  has_many :taggables, through: :taggings

  validates :group, presence: true
  validates :name, presence: true, uniqueness: { scope: :group }
  validates :color, presence: true, format: /\A#([A-F0-9]{3}){1,2}\z/i

  define_counter_cache(:taggings_count) { |tag| tag.taggings.count }
end
