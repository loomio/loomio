BaseModel = require 'shared/record_store/base_model'
AppConfig = require 'shared/services/app_config'

module.exports = class MembershipRequestModel extends BaseModel
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
