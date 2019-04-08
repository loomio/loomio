import AppConfig     from '@/shared/services/app_config'
import Records       from '@/shared/services/records'
import LmoUrlService from '@/shared/services/lmo_url_service'

import { hardReload } from '@/shared/helpers/window'

export default new class Session
  signIn: (userId) ->
    setDefaultParams()
    user = @user()
    @updateLocale(user.locale || AppConfig.defaultLocale)

    return unless AppConfig.currentUserId = userId

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
    # I18n.useLocale(locale)
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
