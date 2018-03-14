module HasAnnouncements
  extend ActiveSupport::Concern
  include HasEvents
  include CustomCounterCache::Model

  included do
    has_many :announcements, through: :events
    has_many :announcees, through: :announcements
    has_many :announcee_users, through: :announcees, source_type: 'User'
    has_many :announcee_groups, through: :announcees, source_type: 'Group'
    has_many :announcee_invitations, through: :announcees, source_type: 'Invitation'

    def users_announced_to
      @users_announced_to ||= User.distinct.where(id: announcees.pluck(:user_ids).flatten)
    end

    define_counter_cache(:announcements_count) { |model| model.announcements.count }
  end
end
