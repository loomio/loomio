class Events::ReactionCreated < Event
  include Events::Notify::InApp
  include Events::LiveUpdate
  include PrettyUrlHelper

  def self.publish!(reaction)
    super(reaction) if reaction.reactable.is_a?(Comment)
  end

  private

  def notification_recipients
    return User.none if !comment ||                # there is no comment
                         user == comment.author || # you liked your own comment
                         !comment.group.memberships.find_by(user: comment.author) # the author has left the group
    User.where(id: comment.author_id)
  end

  def comment
    @comment ||= eventable&.reactable
  end
end
