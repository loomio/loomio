class EmailPreferencesService

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

  def self.update_subscriptions(scope, value)
    scope.update_all(subscribed_to_notification_emails: value)
  end

end
