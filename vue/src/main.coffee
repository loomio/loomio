import 'url-search-params-polyfill'
import '@babel/polyfill'

window.Promise = window.Promise or require 'promise-polyfill' # polyfill for Promise object
require('promise.prototype.finally').shim()                   # polyfill for Promise.finally
require('whatwg-fetch')                                       # polyfill for Fetch API
require('intersection-observer')

# polyfill for Object.entries
if !Object.entries
  Object.entries = (obj) ->
    ownProps = Object.keys(obj)
    i = ownProps.length
    resArray = new Array(i)
    # preallocate the Array
    while i--
      resArray[i] = [
        ownProps[i]
        obj[ownProps[i]]
      ]
    resArray

import Vue from 'vue'
import AppConfig from '@/shared/services/app_config'
import vuetify from '@/vuetify'
import router from '@/routes.coffee'
import i18n from '@/i18n.coffee'
import app from '@/app.vue'
import marked from '@/marked'
import '@/observe_visibility'
# import './registerServiceWorker'
import { initLiveUpdate } from '@/shared/helpers/cable'
import { pick } from 'lodash'
import * as Sentry from '@sentry/browser'
import VueClipboard from 'vue-clipboard2'
import WatchRecords from '@/mixins/watch_records'
import CloseModal from '@/mixins/close_modal'
import UrlFor from '@/mixins/url_for'
import FormatDate from '@/mixins/format_date'
import Vue2TouchEvents from 'vue2-touch-events'
import { initContent } from '@/shared/services/ssr_content'

Vue.use(Vue2TouchEvents)

Vue.mixin(CloseModal)
Vue.mixin(WatchRecords)
Vue.mixin(UrlFor)
Vue.use(VueClipboard)
Vue.mixin(FormatDate)

Vue.config.productionTip = false

import boot from '@/shared/helpers/boot'
import Session from '@/shared/services/session'

boot ->
  Session.fetch().then (data) ->
    Session.apply(data)

    if AppConfig.sentry_dsn
      Sentry.configureScope (scope) ->
        scope.setUser pick(Session.user(), ['id', 'email', 'username'])

    initLiveUpdate()
    initContent()
    new Vue(
      render: (h) -> h(app)
      router: router
      vuetify: vuetify
      i18n: i18n
    ).$mount('#app')
