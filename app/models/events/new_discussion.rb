class Events::NewDiscussion < Event
  include Events::Notify::Users
  include Events::LiveUpdate
  include Events::Notify::ThirdParty

  def self.publish!(discussion)
    create(kind: 'new_discussion',
           user: discussion.author,
           announcement: discussion.make_announcement,
           eventable: discussion).tap { |e| EventBus.broadcast('new_discussion_event', e) }
  end

  private

  def email_recipients
    if announcement
      Queries::UsersByVolumeQuery.normal_or_loud(eventable)
    else
      Queries::UsersByVolumeQuery.loud(eventable)
    end.without(eventable.author).without(eventable.mentioned_group_members)
  end
end
