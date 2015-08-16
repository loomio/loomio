angular.module('loomioApp').factory 'InvitationModel', (BaseModel, AppConfig) ->
  class InvitationModel extends BaseModel
    @singular: 'invitation'
    @plural: 'invitations'
    @indices: ['id', 'groupId']
    @serializableAttributes: AppConfig.permittedParams.invitation

    relationships: ->
      @belongsTo 'group'

    isPending: ->
      !@cancelledAt? && !@acceptedAt?
