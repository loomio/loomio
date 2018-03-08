AppConfig      = require 'shared/services/app_config.coffee'
Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
LmoUrlService  = require 'shared/services/lmo_url_service.coffee'
IntercomService = require 'shared/services/intercom_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'
I18n           = require 'shared/services/i18n.coffee'

{ hardReload } = require 'shared/helpers/window.coffee'

# A series of actions relating to updating the current user, such as signing in
# or changing the app's locale
module.exports =
  signIn: (data, userId, afterSignIn = ->) =>
    Records.import(data)
    Session.signIn(userId, LmoUrlService.params().invitation_token)
    IntercomService.fetch()
    afterSignIn()

  signOut: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> hardReload('/')

  contactUs: ->
    if IntercomService.available()
      IntercomService.open()
    else
      ModalService.open('ContactModal')

  getProviderIdentity: ->
    validProviders = _.pluck(AppConfig.identityProviders, 'name')
    AppConfig.pendingIdentity if _.contains(validProviders, AppConfig.pendingIdentity.identity_type)

  subscribeToLiveUpdate: (options = {}) ->
    return unless AbilityService.isLoggedIn()

    AppConfig.cable.subscriptions.create { channel: "ApplicationChannel" },
      received: (data) ->
        if data.version?
          FlashService.update 'global.messages.app_update', {version: data.version}, 'global.messages.reload', hardReload

    AppConfig.cable.subscriptions.create { channel: "UserChannel" },
      received: (data) ->
        if data.action? && !AppConfig.loggingOut
          AppConfig.loggingOut = true
          ModalService.open 'SignedOutModal', -> preventClose: true
        Records.import(data)

    _.each Session.user().groups(), (group) ->
      AppConfig.cable.subscriptions.create { channel: "GroupChannel", group_id: group.id },
        received: (data) ->
          if data.memo?
            switch data.memo.kind
              when 'comment_destroyed'
                if comment = Records.comments.find(data.memo.data.comment_id)
                  comment.destroy()
          Records.import(data)
