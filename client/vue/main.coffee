import Vue from 'vue'
import VueI18n from 'vue-i18n'
import Vuex from 'vuex'
import Vuetify from 'vuetify'
import VueRouter from 'vue-router'

window.Vue = Vue
window.Vuetify = Vuetify

import colors from 'vuetify/es5/util/colors'

Vue.use(VueI18n)
Vue.use(Vuex)
Vue.use(Vuetify,
  iconfont: 'mdi'
  theme:
    primary: colors.amber.base
    secondary: colors.green.base
    accent: colors.cyan.base
)
Vue.use(VueRouter)

i18n = new VueI18n({locale: 'en', fallbackLocale: 'en'})
require('vue/directives/marked')
moment = require 'moment-timezone'
AppConfig = require 'shared/services/app_config'
{ pluginConfigFor } = require 'shared/helpers/plugin'
{ exportGlobals, hardReload, unsupportedBrowser, initServiceWorker } = require 'shared/helpers/window'
{ bootDat } = require 'shared/helpers/boot'

hardReload('/417.html') if unsupportedBrowser()
exportGlobals()
initServiceWorker()

bootDat (appConfig) ->
  _.merge AppConfig, _.merge appConfig,
    timeZone: moment.tz.guess()
    pendingIdentity: appConfig.userPayload.pendingIdentity
    pluginConfigFor: pluginConfigFor
  window.Loomio = AppConfig

  fetch('/api/v1/translations?lang=en&vue=true').then (res) ->
    res.json().then (data) ->
      i18n.setLocaleMessage('en', data)
      app = require('./app.vue').default
      routes = require('vue/routes.coffee')
      router = new VueRouter(mode: 'history', routes: routes)
      store = require('vue/store/main.coffee')
      new Vue(
        render: (h) -> h(app)
        router: router
        i18n: i18n
        store: store
      ).$mount('#app')
