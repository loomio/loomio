module Ability
  module DiscussionTag
    def initialize(user)
      super(user)

      can [:create, :destroy], ::DiscussionTag do |tag|
        if tag.group.members_can_edit_discussions?
          user_is_member_of?(tag.group_id)
        else
          user_is_author_of?(tag.discussion) or user_is_admin_of?(tag.group_id)
        end
      end
    end
  end
end
