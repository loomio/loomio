class EmailPreferencesService

  def self.update_preferences(email_preferences, attributes)
    group_email_preferences = attributes.delete('group_email_preferences')
    if email_preferences.update_attributes(attributes)
      update_group_notification_preferences_for(email_preferences.user, group_email_preferences)
      if email_preferences.days_to_send == [""] 
        unsubscribe_to_email_summary(email_preferences)
      else
        subscribe_to_email_summary(email_preferences)
      end
      true
    else
      false
    end
  end

  def self.group_memberships_for(user)
    user.memberships.includes(:group).order("groups.name").sort{|a,b| a.group_full_name <=> b.group_full_name }
  end

  def self.group_notification_preferences_for(user)
    user.memberships.where(:subscribed_to_notification_emails => true).
      map(&:id)
  end

  def self.update_group_notification_preferences_for(user, membership_id_strings)
    if membership_id_strings
      membership_ids = membership_id_strings.reject(&:blank?).map(&:to_i)
      update_subscriptions user.memberships, false
      update_subscriptions user.memberships.where(id: membership_ids), true
    end
  end


  private

  def self.subscribe_to_email_summary(email_preferences)
    next_delivery_at = 2.days.from_now
    email_preferences.set_next_activity_summary_sent_at(next_delivery_at)
  end

  def self.unsubscribe_to_email_summary(email_preferences)
    email_preferences.set_next_activity_summary_sent_at(nil)
  end

  def self.update_subscriptions(scope, value)
    scope.update_all(subscribed_to_notification_emails: value)
  end

end