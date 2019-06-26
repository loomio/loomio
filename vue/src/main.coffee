import Vue from 'vue'
import vuetify from '@/vuetify'
import router from '@/routes.coffee'
import i18n from '@/i18n.coffee'
import app from '@/app.vue'
import AppConfig from '@/shared/services/app_config'
import moment from 'moment-timezone'
import marked from '@/marked'
import '@/observe_visibility'
import './registerServiceWorker'

import VueClipboard from 'vue-clipboard2'
Vue.use(VueClipboard)

Vue.config.productionTip = false

# { pluginConfigFor } = require '@/shared/helpers/plugin'
import { exportGlobals, hardReload, unsupportedBrowser } from '@/shared/helpers/window.coffee'
import boot from '@/shared/helpers/boot'
import Session from '@/shared/services/session'
hardReload('/417.html') if unsupportedBrowser()
exportGlobals()

boot ->
  Session.fetch().then (data) ->

    ['shortcut icon', 'apple-touch-icon'].forEach (name) =>
      link = document.createElement('link')
      link.rel = name
      link.href = AppConfig.theme.icon_src
      document.getElementsByTagName('head')[0].appendChild(link)

    Session.apply(data)

    new Vue(
      render: (h) -> h(app)
      router: router
      vuetify: vuetify
      i18n: i18n
    ).$mount('#app')
