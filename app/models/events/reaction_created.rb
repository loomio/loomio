class Events::ReactionCreated < Event
  include Events::Notify::InApp
  include Events::LiveUpdate
  include PrettyUrlHelper

  def self.publish!(reaction)
    create(kind: "reaction_created",
           user: reaction.author,
           eventable: reaction,
           created_at: reaction.created_at).tap { |e| EventBus.broadcast('reaction_created_event', e) }
  end

  private

  def notification_recipients
    return User.none if !reactable ||                             # there is no reactable
                         eventable.author == reactable.author ||  # you liked your own reactable
                         !reactable.group.memberships.find_by(user: reactable.author) # the author has left the group
    User.where(id: reactable.author_id)
  end

  def notification_translation_values
    super.merge(
      reaction:     eventable.reaction.downcase,
      model:        I18n.t(:"notification_models.#{reactable.class.to_s.downcase}"),
      reaction_src: Emojifier.emojify_src!(eventable.reaction.downcase)
    )
  end

  def reactable
    @reactable ||= eventable&.reactable
  end
end
