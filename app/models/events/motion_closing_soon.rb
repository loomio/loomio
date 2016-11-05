class Events::MotionClosingSoon < Event
  def self.publish!(motion)
    create(kind: "motion_closing_soon",
           eventable: motion).tap { |e| EventBus.broadcast('motion_closing_soon_event', e) }
  end

  def users_to_notify
    Queries::UsersByVolumeQuery.normal_or_loud(eventable)
  end

  private

  def notification_actor
    nil
  end
end
