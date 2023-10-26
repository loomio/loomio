/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import Vue from 'vue';
import AppConfig from '@/shared/services/app_config';
import vuetify from '@/vuetify';
import router from '@/routes';
import i18n from '@/i18n';
import app from '@/app.vue';
import marked from '@/marked';
import '@/observe_visibility';
import './removeServiceWorker';
import { pick } from 'lodash';
import * as Sentry from '@sentry/browser';
import WatchRecords from '@/mixins/watch_records';
import CloseModal from '@/mixins/close_modal';
import UrlFor from '@/mixins/url_for';
import FormatDate from '@/mixins/format_date';
import Vue2TouchEvents from 'vue2-touch-events';
import PlausibleService from '@/shared/services/plausible_service';


Vue.use(Vue2TouchEvents);
Vue.mixin(CloseModal);
Vue.mixin(WatchRecords);
Vue.mixin(UrlFor);
Vue.mixin(FormatDate);

Vue.config.productionTip = false;

import boot from '@/shared/helpers/boot';
import Session from '@/shared/services/session';

boot(function(data) {
  Session.apply(data);

  PlausibleService.boot();
  PlausibleService.trackPageview();

  if (AppConfig.sentry_dsn) {
    Sentry.configureScope(scope => scope.setUser(pick(Session.user(), ['id', 'name', 'email', 'username'])));
  }

  return new Vue({
    render(h) { return h(app); },
    router,
    vuetify,
    i18n
  }).$mount('#app');
});
