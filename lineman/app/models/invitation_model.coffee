angular.module('loomioApp').factory 'InvitationModel', (BaseModel) ->
  class InvitationModel extends BaseModel
    @singular: 'invitation'
    @plural: 'invitations'
    @indices: ['id', 'groupId']

    relationships: ->
      @belongsTo 'group'

    isPending: ->
      !@cancelledAt? && !@acceptedAt?
