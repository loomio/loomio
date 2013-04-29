class Announcement < ActiveRecord::Base
  attr_accessible :ends_at, :message, :starts_at, :locale
  validates_presence_of :ends_at, :message, :starts_at, :locale

  def self.current(user)
    result = where("starts_at <= :now and ends_at >= :now", now: Time.zone.now)
    hidden_ids = AnnouncementDismissal.where(user_id: user.id).pluck(:id)
    result = result.where("id not in (?)", hidden_ids) if hidden_ids.present?
    result
  end
end
