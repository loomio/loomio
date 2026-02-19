module Ability::Comment
  def initialize(user)
    super(user)

    can [:create], ::Comment do |comment|
      topic = comment.topic
      topic &&
      !topic.closed_at &&
      topic.members.exists?(user.id)
    end

    can [:update], ::Comment do |comment|
      topic = comment.topic
      topic && !topic.closed_at && (
        (topic.members.exists?(user.id) && comment.author == user && comment.group&.members_can_edit_comments) ||
        (topic.admins.exists?(user.id) && comment.group&.admins_can_edit_user_content)
      )
    end

    can [:discard, :undiscard], ::Comment do |comment|
      topic = comment.topic
      topic && !topic.closed_at &&
      (
        (comment.author == user && topic.members.exists?(user.id)) ||
        topic.admins.exists?(user.id)
      )
    end

    can [:destroy], ::Comment do |comment|
      topic = comment.topic
      topic && !topic.closed_at &&
      Comment.where(parent: comment).count == 0 &&
      (
        topic.admins.exists?(user.id) ||
        (comment.author == user &&
         topic.members.exists?(user.id) &&
         comment.group&.members_can_delete_comments)
      )
    end

    can [:show], ::Comment do |comment|
      topicable = comment.topic&.topicable
      topicable && can?(:show, topicable) && comment.kept?
    end
  end
end
