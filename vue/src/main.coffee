import Vue from 'vue'
import router from '@/routes.coffee'
import i18n from '@/i18n.coffee'
import app from '@/app.vue'
import AppConfig from '@/shared/services/app_config'
import moment from 'moment-timezone'
import marked from '@/marked.coffee'
import vuetify from '@/vuetify.coffee'
import _forEach from 'lodash/forEach'
import _camelCase from 'lodash/camelCase'

import './registerServiceWorker'

Vue.config.productionTip = false

# { pluginConfigFor } = require '@/shared/helpers/plugin'
import { exportGlobals, hardReload, unsupportedBrowser } from '@/shared/helpers/window.coffee'
import { bootDat } from '@/shared/helpers/boot.coffee'
hardReload('/417.html') if unsupportedBrowser()
exportGlobals()

bootDat (appConfig) ->
  _.merge AppConfig, _.merge appConfig,
    timeZone: moment.tz.guess()
    pendingIdentity: appConfig.userPayload.pendingIdentity
    # pluginConfigFor: pluginConfigFor

  window.Loomio = AppConfig

  _forEach Loomio.records, (recordInterface, k) ->
    model = Object.getPrototypeOf(recordInterface).model
    if model && AppConfig.permittedParams[model.singular]
      model.serializableAttributes = AppConfig.permittedParams[model.singular]

  fetch('/api/v1/translations?lang=en&vue=true').then (res) ->
    res.json().then (data) ->
      i18n.setLocaleMessage('en', data)
      # apply serializatable attriburtes
      new Vue(
        render: (h) -> h(app)
        router: router
        i18n: i18n
      ).$mount('#app')
