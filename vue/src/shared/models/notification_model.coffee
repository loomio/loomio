import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'
import { colonToUnicode } from '@/shared/helpers/emojis'
import AnonymousUserModel   from '@/shared/models/anonymous_user_model'

export default class NotificationModel extends BaseModel
  @singular: 'notification'
  @plural: 'notifications'
  @uniqueIndices: ['id']
  @indices: ['eventId', 'userId']

  defaultValues: ->
    title: null
    model: null
    pollType: null
    name: null 
    reaction: null

  relationships: ->
    @belongsTo 'event'
    @belongsTo 'user'
    @belongsTo 'actor', from: 'users'

  actionPath: ->
    switch @kind()
      when 'invitation_accepted' then @actor().username

  href: ->
    return '/' unless @url
    if @kind == 'membership_requested'
      "/" + @url.split('/')[1] + "/members/requests"
    else if @url.startsWith(AppConfig.baseUrl)
      "/" + @url.replace(AppConfig.baseUrl, '')
    else
      "/" + @.url

  args: ->
    actor: @name
    reaction: colonToUnicode(@reaction) if @kind == "reaction_created"
    title: @title
    poll_type: @pollType
    model: @model

  actor: ->
    @actor() || @membershipRequestActor()

  membershipRequestActor: ->
    name = (@name || '').toString()
    Records.users.build
      name: name
      avatarInitials: name.split(' ').map((n) -> n[0]).join('')
      avatarKind: 'initials'

  isRouterLink: ->
    !@url.includes("/invitations/")
