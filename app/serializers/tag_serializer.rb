class TagSerializer < ApplicationSerializer
  attributes :id, :name, :color, :taggings_count, :group_id, :priority
end
