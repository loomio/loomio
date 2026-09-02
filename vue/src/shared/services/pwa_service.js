import { reactive } from 'vue';
import AppConfig from '@/shared/services/app_config';
import EventBus from '@/shared/services/event_bus';
import {
  createPwaLifecycle,
  createPwaState,
  serviceWorkerUrl,
} from '@/shared/services/pwa_lifecycle.mjs';

const state = reactive(createPwaState(window, navigator));
const lifecycle = createPwaLifecycle({
  browserWindow: window,
  browserNavigator: navigator,
  state,
  onUpdateAvailable: () => EventBus.$emit('serviceWorkerUpdate'),
});
lifecycle.startInstallListeners();

export default new class PwaService {
  state = state;
  registrationPromise = null;

  captureInstallPrompt() {
    lifecycle.startInstallListeners();
  }

  async promptInstall() {
    return lifecycle.promptInstall();
  }

  async registration() {
    if (!('serviceWorker' in navigator)) return null;
    if (this.registrationPromise) return this.registrationPromise;

    this.registrationPromise = navigator.serviceWorker.register(
      serviceWorkerUrl(AppConfig.version, AppConfig.release),
      { updateViaCache: 'none' },
    ).then(registration => {
      lifecycle.watchRegistration(registration);
      return registration;
    }).catch(error => {
      // Registration can fail transiently. Allow push settings or a later boot
      // attempt to retry instead of retaining a rejected promise indefinitely.
      this.registrationPromise = null;
      throw error;
    });

    return this.registrationPromise;
  }

  boot() {
    this.captureInstallPrompt();
    return this.registration();
  }

  requestPushUnsubscribe() {
    if (!('serviceWorker' in navigator)) return;

    const controller = navigator.serviceWorker.controller;
    controller?.postMessage({ type: 'UNSUBSCRIBE_PUSH' });
    this.registration().then(registration => {
      if (registration?.active && registration.active !== controller) {
        registration.active.postMessage({ type: 'UNSUBSCRIBE_PUSH' });
      }
    }).catch(() => {});
  }

  activateUpdate() {
    return lifecycle.activateUpdate();
  }
};
