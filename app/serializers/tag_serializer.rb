class TagSerializer < ApplicationSerializer
  attributes :id, :name, :color, :discussion_tags_count, :group_id
end
