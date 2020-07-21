module Ability::Comment
  def initialize(user)
    super(user)

    can [:create], ::Comment do |comment|
      comment.discussion && comment.discussion.members.exists?(user.id)
    end

    can [:update], ::Comment do |comment|
      (comment.discussion.members.exists?(user.id) && comment.author == user && comment.can_be_edited?) ||
      (comment.discussion.admins.exists?(user.id) && comment.group.admins_can_edit_user_content)
    end

    can [:destroy, :discard, :undiscard], ::Comment do |comment|
      (comment.author == user && comment.discussion.members.exists?(user.id)) or comment.discussion.admins.exists?(user.id)
    end

    can [:show], ::Comment do |comment|
      can?(:show, comment.discussion) && comment.kept?
    end
  end
end
