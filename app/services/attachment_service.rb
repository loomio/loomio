class AttachmentService
  def self.create(attachment: attachment, actor: actor)
    attachment.user = actor
    attachment.save!
  end

  def self.destroy(attachment: attachment, actor: actor)
    actor.ability.authorize! :destroy, attachment
    attachment.destroy
  end
end
