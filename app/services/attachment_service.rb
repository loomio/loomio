class AttachmentService
  def self.create(attachment:, actor:)
    actor.ability.authorize! :create, attachment
    attachment.user = actor
    attachment.save!
  end

  def self.destroy(attachment:, actor:)
    actor.ability.authorize! :destroy, attachment
    actor.ability.authorize! :destroy, attachment
    attachment.destroy
  end
end
