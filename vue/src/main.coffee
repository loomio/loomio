import Vue from 'vue'
import AppConfig from '@/shared/services/app_config'
import vuetify from '@/vuetify'
import router from '@/routes.coffee'
import i18n from '@/i18n.coffee'
import app from '@/app.vue'
import moment from 'moment-timezone'
import marked from '@/marked'
import '@/observe_visibility'
import './registerServiceWorker'
import { initLiveUpdate } from '@/shared/helpers/cable'
import { pick } from 'lodash'

import * as Sentry from '@sentry/browser';
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
    Session.apply(data)

    if AppConfig.sentry_dsn
      Sentry.configureScope (scope) =>
        scope.setUser pick(Session.user(), ['id', 'email', 'username'])

    initLiveUpdate()

    new Vue(
      render: (h) -> h(app)
      router: router
      vuetify: vuetify
      i18n: i18n
    ).$mount('#app')
