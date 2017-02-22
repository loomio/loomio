class Events::MotionClosingSoon < Event
  include Events::NotifyUser
  include Events::EmailUser

  def self.publish!(motion)
    create(kind: "motion_closing_soon",
           eventable: motion).tap { |e| EventBus.broadcast('motion_closing_soon_event', e) }
  end

  private

  def notification_recipients
    Queries::UsersByVolumeQuery.normal_or_loud(eventable.discussion)
  end

  def notification_actor
    nil
  end

  def email_recipients
    User.distinct.where.any_of(
      Queries::UsersByVolumeQuery.normal_or_loud(eventable.discussion),
      User.email_proposal_closing_soon_for(eventable.group)
    )
  end
end
