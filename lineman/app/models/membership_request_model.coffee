angular.module('loomioApp').factory 'MembershipRequestModel', (BaseModel) ->
  class MembershipRequestModel extends BaseModel
    @singular: 'membership_request'
    @plural: 'membership_requests'

    initialize: (data) ->
      @id = data.id
      @requestorName = data.name
      @requestorEmail = data.email
      @introduction = data.introduction
      @groupId = data.group_id
      @createdAt = data.createdAt
      @updatedAt = data.updatedAt
      @requestorId = data.requestor_id
      @responderId = data.responder_id
      @response = data.response
      @responded_at = data.responded_at

    serialize: ->

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
