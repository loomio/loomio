class Announcement < ActiveRecord::Base
  attr_accessible :ends_at, :message, :starts_at, :locale
  validates_presence_of :ends_at, :message, :starts_at, :locale
  scope :current, lambda{ where("starts_at <= :now and ends_at > :now", now: Time.zone.now)}

  def self.current_and_not_dismissed_by(user)
    puts "dismissed ids: #{user.dismissed_announcement_ids.inspect}"
    current.where('id not in (?)', user.dismissed_announcement_ids)
  end
end
