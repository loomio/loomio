module Ability::Comment
  def initialize(user)
    super(user)

    can [:create], ::Comment do |comment|
      comment.discussion && comment.discussion.members.exists?(user.id)
    end

    can [:update], ::Comment do |comment|
      comment.discussion.members.exists?(user.id) && comment.author == user && comment.can_be_edited?
    end

    can [:destroy], ::Comment do |comment|
      (comment.author == user && comment.discussion.members.exists?(user.id)) or comment.discussion.admins.exists?(user.id)
    end

    can [:show], ::Comment do |comment|
      can?(:show, comment.discussion)
    end
  end
end
