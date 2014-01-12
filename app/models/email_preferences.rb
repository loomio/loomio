class EmailPreferences < ActiveRecord::Base
  serialize :days_to_send, Array

  belongs_to :user

  validates_presence_of :user_id
  # validates_inclusion_of :days_to_send, in: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

  def all_memberships
    EmailPreferencesService.group_memberships_for(user)
  end

  def group_email_preferences
    EmailPreferencesService.group_notification_preferences_for(user)
  end

  def set_next_activity_summary_sent_at(time)
    update_attribute(:next_activity_summary_sent_at, time)
  end
end
