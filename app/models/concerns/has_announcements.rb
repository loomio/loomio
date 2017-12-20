module HasAnnouncements
  def self.included(base)
    base.include CustomCounterCache::Model
    base.has_many :announcements, as: :announceable
    base.define_counter_cache(:announcements_count) { |model| model.announcements.count }
  end

  def users_from_announcements
    User.where(id: announcements.pluck(:user_ids).flatten)
  end

  def invitations_from_announcements
    Invitation.where(id: announcements.pluck(:invitation_ids).flatten)
  end
end
