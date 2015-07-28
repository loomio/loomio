angular.module('loomioApp').factory 'InvitationModel', (BaseModel) ->
  class InvitationModel extends BaseModel
    @singular: 'invitation'
    @plural: 'invitations'
    @indices: ['id', 'groupId']

    isPending: ->
      !@cancelledAt? && !@acceptedAt?

    group: ->
      @recordStore.groups.find(@groupId)
