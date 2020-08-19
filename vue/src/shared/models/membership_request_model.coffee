import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'
import { capitalize } from 'lodash'

export default class MembershipRequestModel extends BaseModel
  @singular: 'membershipRequest'
  @plural: 'membershipRequests'
  @indices: ['id', 'groupId']

  defaultValues: ->
    introduction: null
    groupId: null

  relationships: ->
    @belongsTo 'group'
    @belongsTo 'requestor', from: 'users'
    @belongsTo 'responder', from: 'users'

  afterConstruction: ->
    name = @name || @email || ''
    @fakeUser =
      name: name
      email: @email
      avatarKind: 'initials'
      constructor: {singular: 'user'}
      avatarInitials: name.split(' ').map((t) -> t[0]).join('')

  actor: ->
    if @byExistingUser() then @requestor() else @fakeUser

  byExistingUser: ->
    @requestorId?

  isPending: ->
    !@respondedAt?

  formattedResponse: ->
    capitalize(@response)
