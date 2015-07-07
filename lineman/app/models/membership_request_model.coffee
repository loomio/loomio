angular.module('loomioApp').factory 'MembershipRequestModel', (BaseModel) ->
  class MembershipRequestModel extends BaseModel
    @singular: 'membershipRequest'
    @plural: 'membershipRequests'
    @indices: ['id', 'groupId']

    initialize: (data) ->
      @baseInitialize(data)
      @fakeUser =
        name: @name
        email: @email
        avatarKind: 'initials'
        avatarInitials: _.map(@name.split(' '), (t) -> t[0]).join('')

    group: ->
      @recordStore.groups.find(@groupId)

    requestor: ->
      @recordStore.users.find(@requestorId)

    responder: ->
      @recordStore.users.find(@responderId)

    actor: ->
      if @byExistingUser()
        @requestor()
      else
        @fakeUser

    byExistingUser: -> @requestorId?

    isPending: ->
      !@respondedAt?

    formattedResponse: ->
      _.capitalize(@response)