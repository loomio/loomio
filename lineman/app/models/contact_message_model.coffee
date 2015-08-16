angular.module('loomioApp').factory 'ContactMessageModel', (BaseModel) ->
  class ContactMessageModel extends BaseModel
    @singular: 'contactMessage'
    @plural: 'contactMessages'
    @serializableAttributes: window.Loomio.permittedParams.contact_message
