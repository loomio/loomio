class Tagging < ActiveRecord::Base
  include CustomCounterCache::Model

  belongs_to :taggable, polymorphic: true
  belongs_to :tag

  update_counter_cache :tag, :taggings_count
end
