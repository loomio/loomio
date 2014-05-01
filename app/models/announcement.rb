class Announcement < ActiveRecord::Base
  validates_presence_of :ends_at, :message, :starts_at, :locale
  scope :current, lambda{ where("starts_at <= :now and ends_at > :now", now: Time.zone.now)}

  def self.current_and_not_dismissed_by(user)
    if user.dismissed_announcement_ids.present?
      current.where('announcements.id not in (?)', user.dismissed_announcement_ids)
    else
      current
    end
  end
end
