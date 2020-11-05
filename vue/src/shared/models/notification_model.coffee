import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'
import { colonToUnicode } from '@/shared/helpers/emojis'

export default class NotificationModel extends BaseModel
  @singular: 'notification'
  @plural: 'notifications'

  relationships: ->
    @belongsTo 'event'
    @belongsTo 'user'
    @belongsTo 'actor', from: 'users', ifNull: -> new AnonymousUser()

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

  path: ->
    if @kind == "reaction_created"
      "notifications.reaction_created_vue"
    else
      "notifications.#{@kind}"

  args: ->
    name: @translationValues.name
    reaction: colonToUnicode(@translationValues.reaction) if @kind == "reaction_created"
    title: @translationValues.title
    poll_type: @translationValues.poll_type
    model: @translationValues.model

  actor: ->
    @actor() || @membershipRequestActor()

  membershipRequestActor: ->
    name = (@translationValues.name || @translationValues.email || '').toString()
    Records.users.build
      name: name
      avatarInitials: name.split(' ').map((n) -> n[0]).join('')
      avatarKind: 'initials'

  isRouterLink: ->
    !@url.includes("/invitations/")
