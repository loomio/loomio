import AppConfig     from '@/shared/services/app_config'
import Records       from '@/shared/services/records'
import LmoUrlService from '@/shared/services/lmo_url_service'
import RestfulClient from '@/shared/record_store/restful_client'
import EventBus      from '@/shared/services/event_bus'
import i18n          from '@/i18n'
import Vue from 'vue'
import { hardReload } from '@/shared/helpers/window'
import { pickBy, identity } from 'lodash'

loadedLanugages = ['en']

setI18nLanguage = (lang) ->
  i18n.locale = lang
  document.querySelector('html').setAttribute('lang', lang)

loadLanguageAsync = (lang) ->
  if (i18n.locale != lang)
    if loadedLanugages.includes(lang)
      setI18nLanguage(lang)
    else
      fetch("/locales/#{lang}.json").then (res) -> res.json().then (data) ->
        loadedLanugages.push(lang)
        i18n.setLocaleMessage(lang, data)
        setI18nLanguage(lang)

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
    loadLanguageAsync(locale)

  providerIdentity: ->
    validProviders = AppConfig.identityProviders.map (p) -> p.name
    AppConfig.pendingIdentity if validProviders.includes(AppConfig.pendingIdentity.identity_type)

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
