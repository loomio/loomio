module Ability::Comment
  def initialize(user)
    super(user)

    can [:create], ::Comment do |comment|
      comment.discussion && comment.discussion.members.include?(user)
    end

    can [:update], ::Comment do |comment|
      comment.discussion.members.include?(user) && comment.author == user && comment.can_be_edited?
    end

    can [:destroy], ::Comment do |comment|
      (comment.author == user && comment.discussion.members.include?(user)) or comment.discussion.admins.include?(user)
    end

    can [:show], ::Comment do |comment|
      can?(:show, comment.discussion)
    end
  end
end
