AppConfig     = require 'shared/services/app_config.coffee'
Records       = require 'shared/services/records.coffee'
I18n          = require 'shared/services/i18n.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

exceptionHandler = require 'shared/helpers/exception_handler.coffee'

{ hardReload } = require 'shared/helpers/window.coffee'

module.exports = new class Session
  signIn: (userId, invitationToken) ->
    setDefaultParams(invitation_token: invitationToken)
    return unless AppConfig.currentUserId = userId
    user = @user()
    exceptionHandler.setUserContext(_.pick(user, "email", "name", "id"))
    @updateLocale()

    if user.timeZone != AppConfig.timeZone
      user.timeZone = AppConfig.timeZone
      Records.users.updateProfile(user)

    user

  signOut: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> hardReload('/')

  user: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build()

  currentGroupId: ->
    @currentGroup? && @currentGroup.id

  updateLocale: ->
    locale = (@user().locale || "en").toLowerCase().replace('_','-')
    I18n.useLocale(locale)
    return if locale == "en"
    Records.momentLocales.fetch(path: "#{momentLocaleFor(locale)}.js").then -> moment.locale(locale)

setDefaultParams = (params) ->
  endpoints = ['stances', 'polls', 'discussions', 'events', 'reactions', 'documents']
  defaultParams = _.pick params, _.identity
  _.each endpoints, (endpoint) ->
    Records[endpoint].remote.defaultParams = _.pick params, _.identity

momentLocaleFor = (locale) ->
  if _.contains AppConfig.momentLocales.valid, locale
    locale
  else
    _.first locale.split('-')
