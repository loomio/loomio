class ContactRequestService
  def self.create(contact_request:, actor:)
    actor.ability.authorize! :create, contact_request

    contact_request.sender = actor
    return unless contact_request.valid?
    contact_request.save!

    EventBus.broadcast 'contact_request_create', contact_request, actor
  end
end
