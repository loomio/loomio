class AttachmentService 
  def self.create(attachment: attachment, actor: actor)
    attachment.user = actor
    attachment.save!
  end
end