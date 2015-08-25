angular.module('loomioApp').factory 'ContactMessageModel', (BaseModel, AppConfig) ->
  class ContactMessageModel extends BaseModel
    @singular: 'contactMessage'
    @plural: 'contactMessages'
    @serializableAttributes: AppConfig.permittedParams.contact_message
