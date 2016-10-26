angular.module('loomioApp').factory 'MembershipRequestModel', (BaseModel, AppConfig) ->
  class MembershipRequestModel extends BaseModel
    @singular: 'membershipRequest'
    @plural: 'membershipRequests'
    @indices: ['id', 'groupId']
    @serializableAttributes: AppConfig.permittedParams.membership_request

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

    charsLeft: ->
      250 - (@introduction or '').toString().length

    overCharLimit: ->
      @charsLeft() < 0
