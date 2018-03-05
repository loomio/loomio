class AnnouncementService
  def self.create(announcement:, actor:)
    actor.ability.authorize! :create, announcement

    announcement.assign_attributes(author: actor)
    # soft create a model_announced event if one needs to be created
    announcement.ensure_event
    return false unless announcement.valid?
    announcement.save!

    EventBus.broadcast 'announcement_create', announcement
    Events::AnnouncementCreated.publish!(announcement)
  end
end
