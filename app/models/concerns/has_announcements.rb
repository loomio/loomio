module HasAnnouncements
  extend ActiveSupport::Concern
  include HasEvents
  include CustomCounterCache::Model

  included do
    has_many :announcements, through: :events
    define_counter_cache(:announcements_count) { |model| model.announcements.count }
  end

  def users_from_announcements
    User.where(id: announcements.pluck(:user_ids).flatten)
  end

  def invitations_from_announcements
    Invitation.where(id: announcements.pluck(:invitation_ids).flatten)
  end

  def create_announced_event!(user)
    events.create(kind: :"#{self.class.downcase}_announced", user: user)
  end
end
