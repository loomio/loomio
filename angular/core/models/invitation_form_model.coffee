angular.module('loomioApp').factory 'InvitationFormModel', (DraftableModel, AppConfig) ->
  class InvitationFormModel extends DraftableModel
    @singular: 'invitationForm'
    @plural: 'invitationForms'
    @draftParent: 'group'
    @serializableFields: ['emails', 'message']

    defaultValues: ->
      emails: ""
      message: ""

    relationships: ->
      @belongsTo 'group'
