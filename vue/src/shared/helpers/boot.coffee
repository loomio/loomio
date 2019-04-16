import 'url-search-params-polyfill';
import RestfulClient from '@/shared/record_store/restful_client'
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import _forEach from 'lodash/forEach'
import _merge from 'lodash/merge'
import i18n from '@/i18n.coffee'

export default (callback) ->
  client = new RestfulClient('boot')
  client.get('site').then (siteResponse) ->
    siteResponse.json().then (appConfig) ->
      _merge AppConfig, _merge appConfig,
        timeZone: moment.tz.guess()

      _forEach Records, (recordInterface, k) ->
        model = Object.getPrototypeOf(recordInterface).model
        if model && AppConfig.permittedParams[model.singular]
          model.serializableAttributes = AppConfig.permittedParams[model.singular]

      fetch('/api/v1/translations?lang=en&vue=true').then (res) ->
        res.json().then (data) ->
          i18n.setLocaleMessage('en', data)
          callback()
