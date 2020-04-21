class TagSerializer < ApplicationSerializer
  attributes :id, :name, :color, :discussion_tags_count
  has_one :group, serializer: GroupSerializer, root: :groups
end
