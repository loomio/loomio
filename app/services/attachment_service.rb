class AttachmentService
  def self.create(attachment:, actor:)
    attachment.user = actor
    attachment.save!
    EventBus.broadcast('attachment_create', attachment, actor)
  end

  def self.destroy(attachment:, actor:)
    actor.ability.authorize! :destroy, attachment
    attachment.destroy
    EventBus.broadcast('attachment_destroy', attachment, actor)
  end
end
