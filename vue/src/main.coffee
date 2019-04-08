import Vue from 'vue'
import VueI18n from 'vue-i18n'
import Vuex from 'vuex'
import Vuetify from 'vuetify'
import VueRouter from 'vue-router'
import routes from '@/routes.coffee'
import store from '@/store/main.coffee'
import app from '@/app.vue'
import AppConfig from '@/shared/services/app_config'
import moment from 'moment-timezone'

import {customRenderer, options, marked} from '@/shared/helpers/marked.coffee'
marked.setOptions Object.assign({renderer: customRenderer()}, options)

render = (el, binding, vnode) ->
  return unless binding.value
  el.innerHTML = marked(binding.value)

Vue.directive 'marked',
  update: render
  bind: render

Vue.config.productionTip = false
import './registerServiceWorker'

window.Vue = Vue
window.Vuetify = Vuetify

import colors from 'vuetify/es5/util/colors'

Vue.prototype.$lt = (value) ->
  if (typeof value == 'string')
    @$t(value)
  else
    path = value.path
    locale = value.locale
    args = value.args
    choice = value.choice
    @$t(path, args)

Vue.use(VueI18n)
Vue.use(Vuex)
Vue.use(Vuetify,
  iconfont: 'mdi'
  theme:
    primary: colors.amber.base
    secondary: colors.green.base
    accent: colors.cyan.base
  options:
    customProperties: true
)
Vue.use(VueRouter)

i18n = new VueI18n({locale: 'en', fallbackLocale: 'en'})
# { pluginConfigFor } = require '@/shared/helpers/plugin'
import { exportGlobals, hardReload, unsupportedBrowser } from '@/shared/helpers/window.coffee'
import { bootDat } from '@/shared/helpers/boot.coffee'
hardReload('/417.html') if unsupportedBrowser()
exportGlobals()

bootDat (appConfig) ->
  debugger
  _.merge AppConfig, _.merge appConfig,
    timeZone: moment.tz.guess()
    pendingIdentity: appConfig.userPayload.pendingIdentity
    # pluginConfigFor: pluginConfigFor

  window.Loomio = AppConfig

  fetch('/api/v1/translations?lang=en&vue=true').then (res) ->
    res.json().then (data) ->
      i18n.setLocaleMessage('en', data)
      router = new VueRouter(mode: 'history', routes: routes)
      # apply serializatable attriburtes
      new Vue(
        render: (h) -> h(app)
        router: router
        i18n: i18n
        store: store
      ).$mount('#app')
