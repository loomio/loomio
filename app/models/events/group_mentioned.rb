class Events::GroupMentioned < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(model, actor, group_ids, parent_event_id)
    super model, user: actor, parent_id: parent_event_id, custom_fields: { group_ids: }
  end

  private

  def already_notified_user_ids
    Event.find(parent_id).recipient_user_ids
  end

  def group_ids
    Group.where(id: custom_fields['group_ids']).filter do |group|
      actor.can? :notify, group
    end.map(&:id)
  end

  def scope
    Membership
      .active
      .accepted
      .where(group_id: group_ids)
      .where.not(user_id: already_mentioned_user_ids)
      .where.not(user_id: already_notified_user_ids)
  end

  def already_mentioned_user_ids
    eventable.mentioned_users.pluck(:id)
  end

  def notification_recipients
    User.where(id: scope.app_notifications.pluck(:user_id))
  end

  def email_recipients
    User.where(id: scope.email_notifications.pluck(:user_id))
  end
end
