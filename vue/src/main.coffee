import 'url-search-params-polyfill'
import 'intersection-observer'
import Vue from 'vue'
import AppConfig from '@/shared/services/app_config'
import vuetify from '@/vuetify'
import router from '@/routes.coffee'
import i18n from '@/i18n.coffee'
import app from '@/app.vue'
import marked from '@/marked'
import '@/observe_visibility'
import './registerServiceWorker'
import { initLiveUpdate } from '@/shared/helpers/cable'
import { pick } from 'lodash'
import * as Sentry from '@sentry/browser'
import VueClipboard from 'vue-clipboard2'
import WatchRecords from '@/mixins/watch_records'
import CloseModal from '@/mixins/close_modal'
import UrlFor from '@/mixins/url_for'
import FormatDate from '@/mixins/format_date'

Vue.mixin(CloseModal)
Vue.mixin(WatchRecords)
Vue.mixin(UrlFor)
Vue.use(VueClipboard)
Vue.mixin(FormatDate)

Vue.config.productionTip = false

import { hardReload, isIncompatibleBrowser } from '@/shared/helpers/window.coffee'
import boot from '@/shared/helpers/boot'
import Session from '@/shared/services/session'

hardReload('/417.html') if isIncompatibleBrowser

boot ->
  Session.fetch().then (data) ->
    Session.apply(data)

    if AppConfig.sentry_dsn
      Sentry.configureScope (scope) ->
        scope.setUser pick(Session.user(), ['id', 'email', 'username'])

    initLiveUpdate()

    new Vue(
      render: (h) -> h(app)
      router: router
      vuetify: vuetify
      i18n: i18n
    ).$mount('#app')
