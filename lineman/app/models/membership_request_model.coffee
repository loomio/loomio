angular.module('loomioApp').factory 'MembershipRequestModel', (BaseModel) ->
  class MembershipRequestModel extends BaseModel
    @singular: 'membershipRequest'
    @plural: 'membershipRequests'
    @indices: ['id', 'groupId']

    # this needs a rethink with more brain power
    initialize: (data) ->
      @baseInitialize(data)
      if !@byExistingUser()
        @fakeUser =
          name: @name
          email: @email
          avatarKind: 'initials'
          avatarInitials: _.map(@name.split(' '), (t) -> t[0]).join('')

    relationships: ->
      @belongsTo 'group'
      @belongsTo 'requestor', from: 'users'
      @belongsTo 'responder', from: 'users'

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
