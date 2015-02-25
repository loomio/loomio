angular.module('loomioApp').factory 'MembershipRequestModel', (BaseModel) ->
  class MembershipRequestModel extends BaseModel
    @singular: 'membership_request'
    @plural: 'membership_requests'

    group: -> @recordStore.groups.find(@groupId)
    requestor: -> @recordStore.users.find(@requestorId)
    responder: -> @recordStore.users.find(@responderId)

    actor: ->
      if @byExistingUser()
        @requestor()
      else
        @fakeUser()

    byExistingUser: -> @requestorId?

    fakeUser: ->
      name: @requestorName
      email: @requestorEmail
      avatarKind: 'initials'
      avatarInitials: 'NA'
