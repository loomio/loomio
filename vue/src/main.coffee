import Vue from 'vue'
import router from '@/routes.coffee'
import i18n from '@/i18n.coffee'
import app from '@/app.vue'
import AppConfig from '@/shared/services/app_config'
import moment from 'moment-timezone'
import marked from '@/marked'
import '@/vuetify'
import '@/observe_visibility'
import './registerServiceWorker'

Vue.config.productionTip = false

# { pluginConfigFor } = require '@/shared/helpers/plugin'
import { exportGlobals, hardReload, unsupportedBrowser } from '@/shared/helpers/window.coffee'
import boot from '@/shared/helpers/boot'
import Session from '@/shared/services/session'
hardReload('/417.html') if unsupportedBrowser()
exportGlobals()

boot ->
  Session.fetch().then (data) ->
    Session.apply(data)

    new Vue(
      render: (h) -> h(app)
      router: router
      i18n: i18n
    ).$mount('#app')
