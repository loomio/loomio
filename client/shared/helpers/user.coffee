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
  signIn: (data, userId, afterSignIn) =>
    Records.import(data)
    Session.signIn(userId, LmoUrlService.params().invitation_token)
    AppConfig.pendingIdentity = data.pending_identity
    FlashService.success data.flash.notice
    IntercomService.fetch()
    afterSignIn() if typeof afterSignIn is 'function'

  signOut: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> hardReload('/')

  contactUs: ->
    if IntercomService.available()
      IntercomService.open()
    else
      ModalService.open('ContactModal')
