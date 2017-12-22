AppConfig = require 'shared/services/app_config.coffee'

angular.module('loomioApp').factory 'InvitationFormModel', (BaseModel) ->
  class InvitationFormModel extends BaseModel
    @singular: 'invitationForm'
    @plural: 'invitationForms'
    @serializableFields: ['emails', 'message']

    defaultValues: ->
      emails: ""
      message: ""

    relationships: ->
      @belongsTo 'group'

    invitees: ->
      # something@something.something where something does not include ; or , or < or >
      @emails.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g) or []

    hasInvitees: ->
      @invitees().length > 0

    hasEmails: ->
      @emails.length > 0
