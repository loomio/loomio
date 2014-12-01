angular.module('loomioApp').factory 'ContactMessageModel', (BaseModel) ->
  class ContactMessageModel extends BaseModel
    @singular: 'contact_message'
    @plural: 'contact_messages'

    constructor: (data) ->
      @name = data.name
      @email = data.email

    serialize: ->
      contact_message:
        name: @name
        email: @email
        message: @message