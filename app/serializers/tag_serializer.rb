class TagSerializer < ApplicationSerializer
  attributes :id, :name, :color, :group_id, :used_group_ids
end
