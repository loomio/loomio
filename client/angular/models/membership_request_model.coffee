BaseModel = require 'shared/models/base_model'
AppConfig = require 'shared/services/app_config.coffee'

angular.module('loomioApp').factory 'MembershipRequestModel', ->
  class MembershipRequestModel extends BaseModel
    @singular: 'membershipRequest'
    @plural: 'membershipRequests'
    @indices: ['id', 'groupId']
    @serializableAttributes: AppConfig.permittedParams.membership_request

    relationships: ->
      @belongsTo 'group'
      @belongsTo 'requestor', from: 'users'
      @belongsTo 'responder', from: 'users'

    afterConstruction: ->
      @fakeUser =
        name: @name
        email: @email
        avatarKind: 'initials'
        constructor: {singular: 'user'}
        avatarInitials: _.map(@name.split(' '), (t) -> t[0]).join('')

    actor: ->
      if @byExistingUser() then @requestor() else @fakeUser

    byExistingUser: -> @requestorId?

    isPending: ->
      !@respondedAt?

    formattedResponse: ->
      _.capitalize(@response)

    charsLeft: ->
      250 - (@introduction or '').toString().length

    overCharLimit: ->
      @charsLeft() < 0
