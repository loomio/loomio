class TagSerializer < ApplicationSerializer
  attributes :id, :name, :color, :discussion_tags_count, :group_id
  has_one :group, serializer: Simple::GroupSerializer, root: :groups
end
