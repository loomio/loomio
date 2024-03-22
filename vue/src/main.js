import AppConfig from '@/shared/services/app_config';
import App from '@/app.vue';
import { createApp } from 'vue';
import markedDirective from '@/marked_directive';
import './removeServiceWorker';
import { pick, each } from 'lodash-es';
import * as Sentry from '@sentry/browser';
// import Vue2TouchEvents from 'vue2-touch-events';
import PlausibleService from '@/shared/services/plausible_service';



import { I18n } from './i18n'
import vuetify from './plugins/vuetify'
import router from './routes'

const useDarkMode = (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches);

import boot from '@/shared/helpers/boot';
import Session from '@/shared/services/session';
import { plugin as Slicksort } from 'vue-slicksort';


boot(function(data) {
  Session.apply(data);

  each(AppConfig.theme.vuetify, (value, key) => {
    if (value) { vuetify.theme.themes.value.light.colors[key] = value; }
    if (value) { vuetify.theme.themes.value.dark.colors[key] = value; }
    return true;
  });

  const app = createApp(App);


  PlausibleService.boot();
  PlausibleService.trackPageview();

  if (AppConfig.sentry_dsn) {
    Sentry.configureScope(scope => scope.setUser(pick(Session.user(), ['id', 'name', 'email', 'username'])));
  }
  app.use(I18n).use(vuetify).use(router).use(Slicksort)
  app.directive('marked', markedDirective)
  app.mount("#app")
});
