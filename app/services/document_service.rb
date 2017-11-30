class DocumentService
  def self.create(document:, actor:)
    actor.ability.authorize! :create, document

    document.assign_attributes(author: actor)
    document.title ||= document.file_file_name
    return unless document.valid?
    document.save!
    document.sync_urls!

    EventBus.broadcast 'document_create', document, actor
  end

  def self.update(document:, params:, actor:)
    actor.ability.authorize! :update, document

    document.assign_attributes(params.slice(:url, :title))

    return unless document.valid?
    document.save!
    document.sync_urls!

    EventBus.broadcast 'document_update', document, params, actor
  end

  def self.destroy(document:, actor:)
    actor.ability.authorize! :destroy, document

    document.destroy

    EventBus.broadcast 'document_destroy', document, actor
  end
end
