import 'url-search-params-polyfill';
import AppConfig     from '@/shared/services/app_config'
import Records       from '@/shared/services/records'
import LmoUrlService from '@/shared/services/lmo_url_service'
import RestfulClient from '@/shared/record_store/restful_client'
import EventBus      from '@/shared/services/event_bus'

import { hardReload } from '@/shared/helpers/window'

export default new class Session
  fetch: ->
    token  = new URLSearchParams(location.search).get('unsubscribe_token')
    client = new RestfulClient('boot')
    client.get('user', unsubscribe_token: token).then (res) -> res.json()

  apply: (data) ->
    AppConfig.currentUserId = data.current_user_id
    AppConfig.pendingIdentity = data.pending_identity
    Records.import(data)

    # afterSignIn() if typeof afterSignIn is 'function'
    # setDefaultParams()

    user = @user()
    if @isSignedIn()
      @updateLocale(user.locale || AppConfig.defaultLocale)

      if user.timeZone != AppConfig.timeZone
        user.timeZone = AppConfig.timeZone
        Records.users.updateProfile(user)
      EventBus.$emit('signedIn', user)

    user

  signOut: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> hardReload('/')

  isSignedIn: ->
    AppConfig.currentUserId

  user: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build()

  currentGroupId: ->
    @currentGroup? && @currentGroup.id

  updateLocale: (locale) ->
    locale = locale.toLowerCase().replace('_','-')
    # TODO I18n.useLocale(locale)
    return if momentLocaleFor(locale) == "en"
    Records.momentLocales.fetch(path: "#{momentLocaleFor(locale)}.js").then -> moment.locale(locale)

  providerIdentity: ->
    validProviders = _.map(AppConfig.identityProviders, 'name')
    AppConfig.pendingIdentity if _.includes(validProviders, AppConfig.pendingIdentity.identity_type)

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


# loggedIn: ->
#   FlashService.success AppConfig.userPayload.flash.notice
# $scope.pageError = null
# $scope.refreshing  = true
# $injector.get('$timeout') ->
#   $scope.refreshing = false
  # FlashService.success AppConfig.userPayload.flash.notice
#   delete AppConfig.userPayload.flash.notice
# if LmoUrlService.params().set_password
#   delete LmoUrlService.params().set_password
#   ModalService.open 'ChangePasswordForm'
