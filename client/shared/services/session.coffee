AppConfig = require 'shared/services/app_config.coffee'
Records   = require 'shared/services/records.coffee'
I18n      = require 'shared/services/i18n.coffee'

{ hardReload } = require 'shared/helpers/window.coffee'

module.exports = new class Session
  signIn: (userId, invitationToken) ->
    defaultParams = _.pick {invitation_token: invitationToken}, _.identity
    Records.stances.remote.defaultParams = defaultParams
    Records.polls.remote.defaultParams   = defaultParams

    return unless AppConfig.currentUserId = userId
    user = @user()
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
    locale = "fr-fr"
    I18n.useLocale(locale)
    return if locale == "en"
    Records.momentLocales.fetch(path: "#{momentLocaleFor(locale)}.js").then -> moment.locale(locale)

momentLocaleFor = (locale) ->
  if _.contains AppConfig.momentLocales.valid, locale
    locale
  else
    _.first locale.split('-')
