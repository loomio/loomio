import Vue from 'vue'
import VueI18n from 'vue-i18n'
import Vuex from 'vuex'
import Vuetify from 'vuetify'
import VueRouter from 'vue-router'
import colors from 'vuetify/es5/util/colors'

window.Vue = Vue
window.Vuetify = Vuetify

Vue.use(VueI18n)
Vue.use(Vuex)
Vue.use(Vuetify, iconfont: 'mdi' )
Vue.use(VueRouter)

require('vue/directives/marked')
moment = require 'moment-timezone'
AppConfig = require 'shared/services/app_config'
{ pluginConfigFor } = require 'shared/helpers/plugin'
{ exportGlobals, hardReload, unsupportedBrowser, initServiceWorker } = require 'shared/helpers/window'
{ bootDat } = require 'shared/helpers/boot'

# import Sidebar from 'vue/components/common/sidebar.vue'

hardReload('/417.html') if unsupportedBrowser()
exportGlobals()
initServiceWorker()

bootDat (appConfig) ->
  _.merge AppConfig, _.merge appConfig,
    timeZone: moment.tz.guess()
    pendingIdentity: appConfig.userPayload.pendingIdentity
    pluginConfigFor: pluginConfigFor
  window.Loomio = AppConfig
  { signIn }                                       = require 'shared/helpers/user'
  FlashService    = require 'shared/services/flash_service'
  routes = require('vue/routes.coffee')
  router = new VueRouter(mode: 'history', routes: routes)
  store = require('vue/store/main.coffee')
  Sidebar = require('vue/components/common/sidebar.vue').default

  i18n = new VueI18n({locale: 'en', fallbackLocale: 'en'})

  fetch('/api/v1/translations?lang=en&vue=true').then (res) ->
    res.json().then (data) ->
      i18n.setLocaleMessage('en', data)
      app = new Vue
        el: '#app'
        theme:
          primary: colors.amber.base
          secondary: colors.green.base
          accent: colors.cyan.base
        components:
          Sidebar: Sidebar
        router: router
        i18n: i18n
        store: store
        methods:
          loggedIn: ->
            FlashService.success AppConfig.userPayload.flash.notice
            # $scope.pageError = null
            # $scope.refreshing = true
            # $injector.get('$timeout') ->
            #   $scope.refreshing = false
              # FlashService.success AppConfig.userPayload.flash.notice
            #   delete AppConfig.userPayload.flash.notice
            # if LmoUrlService.params().set_password
            #   delete LmoUrlService.params().set_password
            #   ModalService.open 'ChangePasswordForm'
        created: ->
          signIn(AppConfig.userPayload, AppConfig.userPayload.current_user_id, @loggedIn)
