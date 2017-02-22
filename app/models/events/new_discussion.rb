class Events::NewDiscussion < Event
  include Events::LiveUpdate
  include Events::EmailUser

  def self.publish!(discussion)
    create(kind: 'new_discussion',
           eventable: discussion).tap { |e| EventBus.broadcast('new_discussion_event', e) }
  end

  private

  def email_recipients
    Queries::UsersByVolumeQuery.normal_or_loud(eventable)
                               .without(eventable.author)
                               .without(eventable.mentioned_group_members)
  end
end
