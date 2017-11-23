module HasAnnouncements
  def self.included(base)
    base.has_many :announcements, as: :announceable

    base.define_counter_cache :announcements_count, -> { |model| model.announcements.count }
  end
end
