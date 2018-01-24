module Ability::Comment
  def initialize(user)
    super(user)

    can [:create], ::Comment do |comment|
      comment.discussion && user_is_member_of?(comment.group.id)
    end

    can [:update], ::Comment do |comment|
      user_is_member_of?(comment.group.id) && user_is_author_of?(comment) && comment.can_be_edited?
    end

    can [:destroy], ::Comment do |comment|
      user_is_author_of?(comment) or user_is_admin_of?(comment.discussion.group_id)
    end

    can [:show], ::Comment do |comment|
      can?(:show, comment.discussion)
    end
  end
end
