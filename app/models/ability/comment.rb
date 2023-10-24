module Ability::Comment
  def initialize(user)
    super(user)

    can [:create], ::Comment do |comment|
      comment.discussion &&
      !comment.discussion.closed_at &&
      comment.discussion.members.exists?(user.id)
    end

    can [:update], ::Comment do |comment|
      !comment.discussion.closed_at && (
        (comment.discussion.members.exists?(user.id) && comment.author == user && comment.group.members_can_edit_comments) ||
        (comment.discussion.admins.exists?(user.id) && comment.group.admins_can_edit_user_content)
      )
    end
    
    can [:discard, :undiscard], ::Comment do |comment|
      !comment.discussion.closed_at &&
      (
        (comment.author == user && comment.discussion.members.exists?(user.id)) ||
        comment.discussion.admins.exists?(user.id)
      )
    end

    can [:destroy], ::Comment do |comment|
      !comment.discussion.closed_at &&
      Comment.where(parent: comment).count == 0 &&
      (
        comment.discussion.admins.exists?(user.id) ||
        (comment.author == user &&
         comment.discussion.members.exists?(user.id) &&
         comment.group.members_can_delete_comments)
      )
    end

    can [:show], ::Comment do |comment|
      can?(:show, comment.discussion) && comment.kept?
    end
  end
end
