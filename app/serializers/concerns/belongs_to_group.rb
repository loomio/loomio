module Concerns::BelongsToGroup
  extend ActiveSupport::Concern

  included do
    has_one :formal_group, serializer: FormalGroupSerializer, root: :groups, key: :group_id
    has_one :guest_group, serializer: GuestGroupSerializer, root: :groups, key: :group_id
  end

  def guest_group
    object.group
  end

  def formal_group
    object.group
  end

  def include_formal_group?
    object.group.is_formal_group?
  end

  def include_guest_group?
    object.group.is_guest_group?
  end
end
