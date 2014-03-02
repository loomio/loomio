class EmailPreference < ActiveRecord::Base

  DAYS = Date::DAYNAMES
  
  serialize :days_to_send, Array

  belongs_to :user

  before_save :set_next_day_to_send
  after_create :set_defaults

  validates_presence_of :user_id
  validate :validate_days_to_send

  def all_memberships
    EmailPreferencesService.group_memberships_for(user)
  end

  def group_email_preferences
    EmailPreferencesService.group_notification_preferences_for(user)
  end

  def subscribed_to_daily_activity_summary_email?
    subscribed_to_daily_activity_email == true
  end

  def subscribed_to_activity_summary_email?
    next_activity_summary_sent_at.present?
  end

  def subscribed_to_mention_notifications?
    subscribed_to_mention_notifications == true
  end

  def subscribed_to_proposal_closure_notifications?
    subscribed_to_proposal_closure_notifications == true
  end

  def set_last_sent_at
    self.activity_summary_last_sent_at = Time.now
  end
  
  def set_next_day_to_send
    days_to_send != [] ? subscribe_to_email_summary : unsubscribe_to_email_summary
  end

  def subscribe_to_email_summary
    set_next_activity_summary_sent_at(next_date_to_send)
  end

  def unsubscribe_to_email_summary
    set_next_activity_summary_sent_at(nil)
  end

  def next_date_to_send
    current_dow = Time.now.wday
    days_as_integers = days_to_send.map{ |day| DateTime.parse(day).wday }
    Date.today + days_before_next_send(days_as_integers, current_dow)
  end

  def days_before_next_send(days_as_integers, current_dow)
    next_dow = days_as_integers.select{ |day| day > current_dow }.take(1).first
    if next_dow.present?
      next_dow - current_dow
    else
      next_dow = days_as_integers.take(1).first
      (7 - current_dow) + next_dow
    end
  end

  def set_next_activity_summary_sent_at(date_to_send)
    date_time_to_send = nil
    if date_to_send
      user_date_time_string = "#{date_to_send.to_s} #{hour_to_send}:00:00 #{user.time_zone}"
      date_time_to_send = Time.parse(user_date_time_string)
    end
    self.next_activity_summary_sent_at = date_time_to_send
  end

  def deactivate!
    update_attributes(:subscribed_to_mention_notifications => false,
                      :subscribed_to_proposal_closure_notifications => false,
                      :days_to_send => [])
  end


  private

  def set_defaults
    days_to_send = []
  end
  
  def validate_days_to_send
    days_to_send.each do |day|
      unless DAYS.include?(day)
        errors.add(:day_list, day + " is not a valid day")
      end
    end
  end
end
