ActionCable = require 'actioncable'

AppConfig      = require 'shared/services/app_config.coffee'
Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
ModalService   = require 'shared/services/modal_service.coffee'
FlashService   = require 'shared/services/flash_service.coffee'
AuthService    = require 'shared/services/auth_service.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

{ hardReload } = require 'shared/helpers/window.coffee'

module.exports = {
  subscribeTo: (model) ->
    subscribeTo(model)

  initLiveUpdate: ->
    subscribeToApplication()

    if AbilityService.isLoggedIn()
      subscribeToUser()
      _.each Session.user().groups(), subscribeToGroup
    else
      subscribeToInvitation()
}

subscribeTo = (model) ->
  switch model.constructor.singular
    when 'group' then subscribeToGroup(model)
    when 'poll'  then subscribeToPoll(model)

subscribeToGroup = (group) ->
  ensureConnection().subscriptions.create { channel: "GroupChannel", group_id: group.id },
    received: (data) ->
      if data.memo?
        switch data.memo.kind
          when 'comment_destroyed'
            if comment = Records.comments.find(data.memo.data.comment_id)
              comment.destroy()
      Records.import(data)

subscribeToUser = ->
  ensureConnection().subscriptions.create { channel: "UserChannel" },
    received: (data) ->
      if data.action? && !AppConfig.loggingOut
        AppConfig.loggingOut = true
        ModalService.open 'SignedOutModal', -> preventClose: true
      Records.import(data)

subscribeToInvitation = ->
  return unless invitationToken()
  ensureConnection().subscriptions.create { channel: "InvitationChannel" },
    received: (data) ->
      switch data.action
        when 'accepted' then AuthService.signIn().then -> hardReload()

subscribeToPoll = (poll) ->
  ensureConnection().subscriptions.create { channel: "PollChannel", poll_id: poll.id },
    received: (data) -> Records.import(data)

subscribeToApplication = ->
  ensureConnection().subscriptions.create { channel: "ApplicationChannel" },
    received: (data) ->
      if data.version?
        FlashService.update 'global.messages.app_update', {version: data.version}, 'global.messages.reload', hardReload

ensureConnection = ->
  AppConfig.cable = AppConfig.cable or if invitationToken()
    ActionCable.createConsumer("/cable?token=#{invitationToken()}")
  else
    ActionCable.createConsumer("/cable")

invitationToken = ->
  (AppConfig.pendingIdentity || {}).token
