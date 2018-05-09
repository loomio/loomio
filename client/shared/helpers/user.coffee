AppConfig      = require 'shared/services/app_config'
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'
LmoUrlService  = require 'shared/services/lmo_url_service'
IntercomService = require 'shared/services/intercom_service'
ModalService   = require 'shared/services/modal_service'
FlashService   = require 'shared/services/flash_service'

{ hardReload } = require 'shared/helpers/window'

# A series of actions relating to updating the current user, such as signing in
# or changing the app's locale
module.exports =
  signIn: (data, userId, afterSignIn) =>
    Records.import(data)
    Session.signIn(userId)
    AppConfig.pendingIdentity = data.pending_identity
    FlashService.success data.flash.notice
    IntercomService.fetch()
    afterSignIn() if typeof afterSignIn is 'function'

  signOut: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> hardReload('/')

  getProviderIdentity: ->
    validProviders = _.pluck(AppConfig.identityProviders, 'name')
    AppConfig.pendingIdentity if _.contains(validProviders, AppConfig.pendingIdentity.identity_type)

  contactUs: ->
    if IntercomService.available()
      IntercomService.open()
    else
      ModalService.open('ContactModal')
