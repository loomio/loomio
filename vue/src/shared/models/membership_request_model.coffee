import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class MembershipRequestModel extends BaseModel
  @singular: 'membershipRequest'
  @plural: 'membershipRequests'
  @indices: ['id', 'groupId']

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
