class AnnouncementService
  def self.create(announcement:, actor:)
    actor.ability.authorize! :create, announcement

    announcement.author = actor
    return false unless announcement.valid?

    announcement.save!

    EventBus.broadcast 'announcement_create', announcement
    Events::AnnouncementCreated.publish!(announcement)
  end
end
