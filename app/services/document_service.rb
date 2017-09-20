class DocumentService
  def self.create(document:, actor:)
    actor.ability.authorize! :create, document

    return unless document.valid?
    document.save!

    EventBus.broadcast 'document_create', document, actor
  end

  def self.destroy(document:, actor:)
    actor.ability.authorize! :destroy, document

    document.destroy

    EventBus.broadcast 'document_destroy', document, actor
  end
end
