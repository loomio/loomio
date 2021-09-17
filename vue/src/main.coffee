require('intersection-observer')
import Vue from 'vue'
import AppConfig from '@/shared/services/app_config'
import vuetify from '@/vuetify'
import router from '@/routes.coffee'
import i18n from '@/i18n.coffee'
import app from '@/app.vue'
import marked from '@/marked'
import '@/observe_visibility'
import './removeServiceWorker'
import { pick } from 'lodash'
import * as Sentry from '@sentry/browser'
import VueClipboard from 'vue-clipboard2'
import WatchRecords from '@/mixins/watch_records'
import CloseModal from '@/mixins/close_modal'
import UrlFor from '@/mixins/url_for'
import FormatDate from '@/mixins/format_date'
import Vue2TouchEvents from 'vue2-touch-events'
import { initContent } from '@/shared/services/ssr_content'
import posthog from 'posthog-js';

Vue.use(Vue2TouchEvents)

Vue.mixin(CloseModal)
Vue.mixin(WatchRecords)
Vue.mixin(UrlFor)
Vue.use(VueClipboard)
Vue.mixin(FormatDate)

Vue.config.productionTip = false

import boot from '@/shared/helpers/boot'
import Session from '@/shared/services/session'

boot (data) ->
  Session.apply(data)

  if AppConfig.posthog_key
    posthog.init(AppConfig.posthog_key, {api_host: AppConfig.posthog_host});
    posthog.identify Session.user().id, pick(Session.user(), ['name', 'email', 'username'])

  if AppConfig.sentry_dsn
    Sentry.configureScope (scope) ->
      scope.setUser pick(Session.user(), ['id', 'name', 'email', 'username'])

  initContent()
  new Vue(
    render: (h) -> h(app)
    router: router
    vuetify: vuetify
    i18n: i18n
  ).$mount('#app')
