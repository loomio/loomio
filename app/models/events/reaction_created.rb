class Events::ReactionCreated < Event
  include Events::Notify::InApp
  include Events::LiveUpdate
  include PrettyUrlHelper

  def self.publish!(reaction)
    super reaction, user: reaction.user
  end

  private

  def notification_recipients
    return User.none if !reactable ||                             # there is no reactable
                         reactable.author == user ||              # you liked your own reactable
                         !reactable.group.memberships.find_by(user: user) # the author has left the group
    User.where(id: reactable.author_id)
  end

  def notification_translation_values
    super.merge(
      reaction:     eventable.reaction.downcase,
      reaction_src: Emojifier.emojify_src!(eventable.reaction.downcase)
    )
  end

  def reactable
    @reactable ||= eventable&.reactable
  end
end
