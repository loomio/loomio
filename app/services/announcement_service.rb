class AnnouncementService
  def self.create(announcement:, actor:)
    actor.ability.authorize! :create, announcement

    announcement.author = actor
    return false unless announcement.valid?

    announcement.invitation_ids = InvitationService.bulk_create(
      recipient_emails: announcement.invitation_emails,
      group:            announcement.guest_group,
      inviter:          announcement.author,
      send_emails:      false
    ).map(&:id)
    announcement.save!

    EventBus.broadcast 'announcement_create', announcement
    Events::AnnouncementCreated.publish!(announcement)
  end
end
