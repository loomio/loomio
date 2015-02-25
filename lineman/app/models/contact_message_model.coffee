angular.module('loomioApp').factory 'ContactMessageModel', (BaseModel) ->
  class ContactMessageModel extends BaseModel
    @singular: 'contact_message'
    @plural: 'contact_messages'
