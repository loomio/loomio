import Vue from 'vue'
import RestfulClient from '@/shared/record_store/restful_client'
import AppConfig from '@/shared/services/app_config'
import Records from '@/shared/services/records'
import i18n from '@/i18n.coffee'
import * as Sentry from '@sentry/vue'
import { BrowserTracing } from "@sentry/tracing"
import { forEach, snakeCase } from 'lodash'
import router from '@/routes.coffee'

export default (callback) ->
  client = new RestfulClient('boot')
  client.get('site').then (appConfig) ->
    appConfig.timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone
    forEach appConfig, (v, k) -> Vue.set(AppConfig, k, v)

    if AppConfig.sentry_dsn
      Sentry.init
        ignoreErrors: [
          "Avoided redundant navigation to current location",
          "NotFoundError: Node.removeChild",
          "NotFoundError: Failed to execute 'removeChild' on 'Node'",
          "NotFoundError: The object can not be found here",
          "NotFoundError: Node was not found",
          "null is not an object (evaluating 'r.addEventListener')",
          "Cannot read property 'addEventListener' of null",
          "evaluating 't.addEventListener'",
          "ResizeObserver loop limit exceeded",
          "MetaMask detected another web3",
          "AbortError: The operation was aborted",
          "ResizeObserver loop completed with undelivered notifications",
          "TypeError: cancelled",
          "UnhandledRejection: Non-Error promise rejection captured with value",
          "ChunkLoadError: Loading chunk chunk-",
          "TypeError: annulé",
          "Permission denied to access property \"dispatchEvent\" on cross-origin object",
          "TypeError: Failed to fetch",
          "Object captured as promise rejection with keys: error, ok, status, statusText",
          "Object captured as promise rejection with keys: exception, ok, status, statusText",
          "Non-Error promise rejection captured with keys: exception, ok, status, statusText"
        ]
        dsn: AppConfig.sentry_dsn
        tunnel: '/bug_tunnel'
        integrations: [
          new BrowserTracing({
            routingInstrumentation: Sentry.vueRouterInstrumentation(router),
            tracingOrigins: ["localhost", AppConfig.baseUrl, /^\//],
          }),
        ]
        tracesSampleRate: AppConfig.features.app.sentry_sample_rate

      Sentry.configureScope (scope) ->
        scope.setTag("loomio_version", AppConfig.version)

    ['shortcut icon'].forEach (name) ->
      link = document.createElement('link')
      link.rel = name
      link.href = AppConfig.theme.icon_src
      document.getElementsByTagName('head')[0].appendChild(link)

    forEach Records, (recordInterface, k) ->
      model = Object.getPrototypeOf(recordInterface).model
      if model && AppConfig.permittedParams[snakeCase(model.singular)]
        model.serializableAttributes = AppConfig.permittedParams[snakeCase(model.singular)]

    callback(appConfig)
