module Ability
  module Tag
    def initialize(user)
      super(user)

      can [:create, :update, :destroy], ::Tag do |tag|
        user_is_admin_of?(tag.group_id)
      end

      can :show, ::Tag do |tag|
        tag.group.is_visible_to_public? or
        user_is_member_of?(tag.group_id) or
        (tag.group.is_visible_to_parent_members? && user_is_member_of?(tag.group.parent_id))
      end
    end
  end
end
