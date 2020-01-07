import AppConfig     from '@/shared/services/app_config'
import Records       from '@/shared/services/records'
import LmoUrlService from '@/shared/services/lmo_url_service'
import RestfulClient from '@/shared/record_store/restful_client'
import EventBus      from '@/shared/services/event_bus'
import i18n          from '@/i18n'
import Vue from 'vue'
import { hardReload } from '@/shared/helpers/window'
import { pickBy, identity, compact } from 'lodash'

loadedLocales = ['en']

setI18nLanguage = (locale) ->
  i18n.locale = locale
  document.querySelector('html').setAttribute('lang', locale)


fixCase = (locale) ->
  splits = locale.replace('-', '_').split('_')
  compact([splits[0].toLowerCase(), splits[1] && splits[1].toUpperCase()]).join('_')

loomioLocale = (locale) ->
  locale.replace('-', '_')

dateFnsLocale = (locale) ->
  locale.replace('_','-')

loadLocale = (locale) ->
  if (i18n.locale != locale)
    if loadedLocales.includes(locale)
      setI18nLanguage(locale)
    else
      import("date-fns/locale/#{dateFnsLocale(locale)}/index.js").then (dateLocale) ->
        i18n.dateLocale = dateLocale
      import("@/../../config/locales/client.#{loomioLocale(locale)}.yml").then (data) ->
        data = data[locale]
        loadedLocales.push(locale)
        i18n.setLocaleMessage(locale, data)
        setI18nLanguage(locale)

export default new class Session
  fetch: ->
    # unsubscribe_token = new URLSearchParams(location.search).get('unsubscribe_token')
    # membership_token  = new URLSearchParams(location.search).get('membership_token')
    client = new RestfulClient('boot')
    # client.get('user', unsubscribe_token: unsubscribe_token, membership_token: membership_token).then (res) -> res.json()
    client.get('user').then (res) -> res.json()

  apply: (data) ->
    Vue.set(AppConfig, 'currentUserId', data.current_user_id)
    Vue.set(AppConfig, 'pendingIdentity', data.pending_identity)
    Records.import(data)

    # afterSignIn() if typeof afterSignIn is 'function'
    # setDefaultParams()

    user = @user()
    if @isSignedIn()
      @updateLocale(user.locale)

      if user.timeZone != AppConfig.timeZone
        user.timeZone = AppConfig.timeZone
        Records.users.updateProfile(user)

      EventBus.$emit('signedIn', user)

    user

  signOut: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> hardReload('/')

  isSignedIn: ->
    AppConfig.currentUserId and !@user().restricted?

  user: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build()

  currentGroupId: ->
    @currentGroup? && @currentGroup.id

  updateLocale: (locale) ->
    loadLocale(locale)

  providerIdentity: ->
    validProviders = AppConfig.identityProviders.map (p) -> p.name
    AppConfig.pendingIdentity if validProviders.includes(AppConfig.pendingIdentity.identity_type)

  pendingInvitation: ->
    AppConfig.pendingIdentity.identity_type?

setDefaultParams = (params) ->
  endpoints = ['stances', 'polls', 'discussions', 'events', 'reactions', 'documents']
  defaultParams = pickBy(params, identity)
  endpoints.forEach (endpoint) ->
    Records[endpoint].remote.defaultParams = defaultParams

# loggedIn: ->
#   Flash.success AppConfig.userPayload.flash.notice
# $scope.pageError = null
# $scope.refreshing  = true
# $injector.get('$timeout') ->
#   $scope.refreshing = false
  # Flash.success AppConfig.userPayload.flash.notice
#   delete AppConfig.userPayload.flash.notice
# if LmoUrlService.params().set_password
#   delete LmoUrlService.params().set_password
#   ModalService.open 'ChangePasswordForm'
