class Events::NewMotion < Event
  include Events::LiveUpdate
  include Events::EmailUser
  include Events::JoinDiscussion

  def self.publish!(motion)
    create(kind: "new_motion",
           eventable: motion,
           discussion: motion.discussion,
           created_at: motion.created_at).tap { |e| EventBus.broadcast('new_motion_event', e) }
  end

  private

  def email_recipients
    Queries::UsersByVolumeQuery.normal_or_loud(eventable.discussion)
                               .without(eventable.author)
                               .without(eventable.mentioned_group_members)

  end
end
