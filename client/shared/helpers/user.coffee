AppConfig      = require 'shared/services/app_config.coffee'
Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
LmoUrlService  = require 'shared/services/lmo_url_service.coffee'
I18n           = require 'shared/services/i18n.coffee'

moment = require 'moment'
require 'private_pub' # this sets window.PrivatePub, because private_pub is too old to be a module :)

{ hardReload } = require 'shared/helpers/window.coffee'

# A series of actions relating to updating the current user, such as signing in
# or changing the app's locale
module.exports =
  signIn: (data, callback) =>
    Session.signIn(data, LmoUrlService.params().invitation_token)
    callback() if typeof callback == 'function'

  signOut: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> hardReload('/')

  subscribeToLiveUpdate: (options = {}) ->
    return unless AbilityService.isLoggedIn()
    Records.messageChannel.remote.post('subscribe', options).then (subscriptions) ->
      _.each subscriptions, (subscription) ->
        PrivatePub.sign(subscription)
        PrivatePub.subscribe subscription.channel, (data) ->
          liveUpdateAction(data)       if data.action?
          liveUpdateVersion(data)      if data.version?
          liveUpdateMemo(data)         if data.memo?
          liveUpdateEvent(data)        if data.event?
          liveUpdateNotification(data) if data.notification?
          Records.import(data)

liveUpdateAction = (data) ->
  if data.action == 'logged_out' && !AppConfig.loggingOut
    ModalService.open 'SignedOutModal', -> preventClose: true

liveUpdateVersion = (data) ->
  FlashService.update 'global.messages.app_update', {version: data.version}, 'global.messages.reload', hardReload

liveUpdateMemo = (data) ->
  switch data.memo.kind
    when 'comment_destroyed'
      if comment = Records.comments.find(memo.data.comment_id)
        comment.destroy()
    when 'comment_updated'
      Records.comments.import(memo.data.comment)
      Records.import(memo.data)
    when 'comment_unliked'
      if comment = Records.comments.find(memo.data.comment_id)
        comment.removeLikerId(memo.data.user_id)

liveUpdateEvent = (data) ->
  data.events = [] unless _.isArray(data.events)
  data.events.push(data.event)

liveUpdateNotification = (data) ->
  data.notifications = [] unless _.isArray(data.notifications)
  data.notifications.push(data.notification)
