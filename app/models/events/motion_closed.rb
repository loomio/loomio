class Events::MotionClosed < Event
  include Events::NotifyUser
  include Events::EmailUser
  include Events::JoinDiscussion

  def self.publish!(motion)
    create(kind: 'motion_closed',
           eventable: motion,
           discussion_id: motion.discussion_id).tap { |e| EventBus.broadcast('motion_closed_event', e) }
  end

  private

  def notification_recipients
    User.where(id: eventable.author_id)
  end

  def notification_url
    discussion_motion_outcome_url(eventable.discussion, eventable)
  end

  def notification_translation_values
    super.merge(publish_outcome: true)
  end

  def notification_actor
    nil
  end

  def email_recipients
    Queries::UsersByVolumeQuery.normal_or_loud(eventable.discussion)
  end
end
