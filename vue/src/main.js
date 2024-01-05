import AppConfig from '@/shared/services/app_config';
// import router from '@/routes';
// import I18n from '@/i18n';
import App from '@/app.vue';
import { createApp } from 'vue';
import markedDirective from '@/marked_directive';
// import '@/observe_visibility';
import './removeServiceWorker';
import { pick } from 'lodash-es';
// import * as Sentry from '@sentry/browser';
// import Vue2TouchEvents from 'vue2-touch-events';
// import PlausibleService from '@/shared/services/plausible_service';
// import Session from '@/shared/services/session';


const app = createApp(App);

import i18n from './i18n'
import vuetify from './plugins/vuetify'
import router from './routes'

const useDarkMode = (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches);

// Vue.use(Vue2TouchEvents);
// Vue.mixin(CloseModal);
// Vue.mixin(WatchRecords);
// Vue.mixin(UrlFor);
// Vue.mixin(FormatDate);

// Vue.config.productionTip = false;

import boot from '@/shared/helpers/boot';
import Session from '@/shared/services/session';
import { plugin as Slicksort } from 'vue-slicksort';

boot(function(data) {
  Session.apply(data);

  // PlausibleService.boot();
  // PlausibleService.trackPageview();

  // if (AppConfig.sentry_dsn) {
  //   Sentry.configureScope(scope => scope.setUser(pick(Session.user(), ['id', 'name', 'email', 'username'])));
  // }
  app.use(i18n).use(vuetify).use(router).use(Slicksort)
  app.directive('marked', markedDirective)
  app.mount("#app")

  // return new Vue({
  //   render(h) { return h(app); },
  //   router,
  //   vuetify,
  //   i18n
  // }).$mount('#app');
});
