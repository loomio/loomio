import 'url-search-params-polyfill'
import Vue from 'vue'
import RestfulClient from '@/shared/record_store/restful_client'
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import i18n from '@/i18n.coffee'
import * as Sentry from '@sentry/browser'
import * as Integrations from '@sentry/integrations'
import { forEach } from 'lodash'
import * as moment from 'moment'

export default (callback) ->
  client = new RestfulClient('boot')
  client.get('site').then (siteResponse) ->
    siteResponse.json().then (appConfig) ->
      appConfig.timeZone = moment.tz.guess()
      forEach appConfig, (v, k) -> Vue.set(AppConfig, k, v)

      if AppConfig.sentry_dsn
        Sentry.init
          dsn: AppConfig.sentry_dsn
          integrations: [
            new Integrations.Vue
              Vue: Vue
              attachProps: true
          ]

      ['shortcut icon', 'apple-touch-icon'].forEach (name) =>
        link = document.createElement('link')
        link.rel = name
        link.href = AppConfig.theme.icon_src
        document.getElementsByTagName('head')[0].appendChild(link)

      forEach Records, (recordInterface, k) ->
        model = Object.getPrototypeOf(recordInterface).model
        if model && AppConfig.permittedParams[model.singular]
          model.serializableAttributes = AppConfig.permittedParams[model.singular]

      fetch('/api/v1/translations?lang=en&vue=true').then (res) ->
        res.json().then (data) ->
          i18n.setLocaleMessage('en', data)
          callback()
