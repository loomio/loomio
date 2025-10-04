import AppConfig from '@/shared/services/app_config';
import App from '@/app.vue';
import { createApp } from 'vue';
import markedDirective from '@/marked_directive';
import './removeServiceWorker';
import { pick } from 'lodash-es';
import * as Sentry from '@sentry/browser';
import PlausibleService from '@/shared/services/plausible_service';

try {
  document.querySelectorAll("link[rel=stylesheet][href*=themeauto]")[0].remove();
} catch {
  // noop
}

import { I18n } from './i18n'
import vuetify from './plugins/vuetify'
import router from './routes'

import boot from '@/shared/helpers/boot';
import Session from '@/shared/services/session';
import { plugin as Slicksort } from 'vue-slicksort';

boot(function(data) {
  Session.apply(data);

  const app = createApp(App);
  if (AppConfig.sentry_dsn) {
    Sentry.init({
      app,
      dsn: AppConfig.sentry_dsn,
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
      ],
      tunnel: '/bug_tunnel',
      integrations: [Sentry.browserTracingIntegration({ router })],
      tracesSampleRate: AppConfig.features.app.sentry_sample_rate,
      tracePropagationTargets: ["localhost", AppConfig.baseUrl, /^\//],
    });

    Sentry.setTag("loomio_version", AppConfig.version);
    Sentry.setUser(pick(Session.user(), ['id', 'name', 'email', 'username']));
  }

  PlausibleService.boot();
  PlausibleService.trackPageview();

  app.use(I18n).use(vuetify).use(router).use(Slicksort)
  app.directive('marked', markedDirective)
  app.mount("#app")
});
