AppConfig     = require 'shared/services/app_config'
Records       = require 'shared/services/records'
I18n          = require 'shared/services/i18n'
LmoUrlService = require 'shared/services/lmo_url_service'

exceptionHandler = require 'shared/helpers/exception_handler'

{ hardReload } = require 'shared/helpers/window'

module.exports = new class Session
  signIn: (userId) ->
    setDefaultParams()
    user = @user()
    @updateLocale(user.locale || AppConfig.defaultLocale)

    return unless AppConfig.currentUserId = userId
    exceptionHandler.setUserContext(_.pick(user, ["email", "name", "id"]))

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

  updateLocale: (locale) ->
    locale = locale.toLowerCase().replace('_','-')
    I18n.useLocale(locale)
    return if momentLocaleFor(locale) == "en"
    Records.momentLocales.fetch(path: "#{momentLocaleFor(locale)}.js").then -> moment.locale(locale)

setDefaultParams = (params) ->
  endpoints = ['stances', 'polls', 'discussions', 'events', 'reactions', 'documents']
  defaultParams = _.pickBy(params, _.identity)
  _.each endpoints, (endpoint) ->
    Records[endpoint].remote.defaultParams = defaultParams

momentLocaleFor = (locale) ->
  if _.includes AppConfig.momentLocales.valid, locale
    locale
  else
    _.head locale.split('-')
