class Events::CommentAnnounced < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(model, actor, audiences)
    super model,
          user: actor,
          custom_fields: { audiences: }
  end

  private

  def email_recipients
    notification_recipients.where(email_when_mentioned: true)
  end

  def notification_recipients
    recipients_ids = custom_fields['audiences'].inject([]) do |ids, audience|
                      ids |= AnnouncementService.audience_users(eventable,
                                                                Audience.send(audience).alias,
                                                                eventable.author,
                                                                false,
                                                                false).pluck(:id)
    end

    User.where(id: recipients_ids)
        .where.not(id: eventable.already_mentioned_users.pluck(:id))
  end
end