angular.module('loomioApp').factory 'InvitationModel', (BaseModel, AppConfig) ->
  class InvitationModel extends BaseModel
    @singular: 'invitation'
    @plural: 'invitations'
    @indices: ['groupId']
    @serializableAttributes: AppConfig.permittedParams.invitation
    @draftPayloadAttributes: ['emails', 'message']

    relationships: ->
      @belongsTo 'group'

    isPending: ->
      !@cancelledAt? && !@acceptedAt?
