import AppConfig from '@/shared/services/app_config';
import RestfulClient from '@/shared/record_store/restful_client';
import { requiresHomeScreen } from '@/shared/services/push_subscription_support.mjs';

const client = new RestfulClient('push_subscriptions');

function applicationServerKey(value) {
  const padding = '='.repeat((4 - value.length % 4) % 4);
  const base64 = (value + padding).replace(/-/g, '+').replace(/_/g, '/');
  return Uint8Array.from(atob(base64), character => character.charCodeAt(0));
}

export default new class PushSubscriptionService {
  mutationPromise = Promise.resolve();
  registrationPromise = null;

  supported() {
    return !this.requiresHomeScreen() &&
      AppConfig.webPushEnabled &&
      window.isSecureContext &&
      'Notification' in window &&
      'serviceWorker' in navigator &&
      'PushManager' in window;
  }

  permission() {
    return 'Notification' in window ? Notification.permission : 'unsupported';
  }

  requiresHomeScreen() {
    return requiresHomeScreen(window, navigator);
  }

  async registration() {
    if (!('serviceWorker' in navigator)) return null;
    if (this.registrationPromise) return this.registrationPromise;

    this.registrationPromise = navigator.serviceWorker.register('/service-worker.js').catch(error => {
      // Registration can fail transiently. Allow a later push operation to retry.
      this.registrationPromise = null;
      throw error;
    });

    return this.registrationPromise;
  }

  async existing() {
    if (!this.supported()) return null;
    const registration = await navigator.serviceWorker.getRegistration();
    return registration?.pushManager.getSubscription() || null;
  }

  async enabled() {
    return !!(await this.existing());
  }

  enable(name = null) {
    if (!this.supported()) return Promise.reject(new Error('push_not_supported'));

    // Safari requires the permission prompt to begin directly within the click's
    // user activation. Do not defer this call through the mutation queue.
    const permissionPromise = Notification.requestPermission();

    return this.enqueueMutation(async () => {
      const permission = await permissionPromise;
      if (permission !== 'granted') throw new Error('push_permission_denied');

      const registration = await this.registration();
      let subscription = await registration.pushManager.getSubscription();
      const didCreateSubscription = !subscription;
      subscription ||= await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: applicationServerKey(AppConfig.vapidPublicKey)
      });

      try {
        await client.create(this.subscriptionParams(subscription, name));
        return subscription;
      } catch (error) {
        if (didCreateSubscription) await subscription.unsubscribe().catch(() => {});
        throw error;
      }
    });
  }

  // Restore server ownership for a subscription the browser already owns.
  // This never requests permission, creates a browser subscription, or revives
  // an endpoint that was explicitly removed from the device list.
  reconcile() {
    return this.enqueueMutation(async () => {
      if (!this.supported()) return null;
      const subscription = await this.existing();
      if (!subscription) return null;

      await this.registration();
      const response = await client.post('reconcile', this.subscriptionParams(subscription));
      if (response.enabled === false) {
        await subscription.unsubscribe();
        return null;
      }
      return subscription;
    });
  }

  disable() {
    return this.enqueueMutation(async () => {
      if (!this.supported()) return;
      const subscription = await this.existing();
      if (!subscription) return;

      try {
        await client.delete('', { endpoint: subscription.endpoint });
      } finally {
        await subscription.unsubscribe();
      }
    });
  }

  async disableBrowser() {
    this.requestWorkerUnsubscribe();
    if (!this.supported()) return;
    const subscription = await this.existing();
    if (subscription) await subscription.unsubscribe();
  }

  // Start cleanup through the controlling worker before logout reloads the page.
  // Also notify a different active worker when an update changed controllers.
  requestWorkerUnsubscribe() {
    if (!('serviceWorker' in navigator)) return;

    const controller = navigator.serviceWorker.controller;
    controller?.postMessage({ type: 'UNSUBSCRIBE_PUSH' });
    navigator.serviceWorker.getRegistration().then(registration => {
      if (registration?.active && registration.active !== controller) {
        registration.active.postMessage({ type: 'UNSUBSCRIBE_PUSH' });
      }
    }).catch(() => {});
  }

  async subscriptions() {
    if (!AppConfig.webPushEnabled) return [];
    const data = await client.get('');
    return data.push_subscriptions || [];
  }

  sendTest() {
    return client.post('send_test', {});
  }

  enqueueMutation(callback) {
    const mutation = this.mutationPromise.catch(() => {}).then(callback);
    this.mutationPromise = mutation;
    return mutation;
  }

  subscriptionParams(subscription, name) {
    const value = subscription.toJSON();
    const pushSubscription = {
      endpoint: value.endpoint,
      p256dh_key: value.keys.p256dh,
      auth_key: value.keys.auth,
      expires_at: value.expirationTime ? new Date(value.expirationTime).toISOString() : null
    };
    if (name != null) pushSubscription.name = name;
    return { push_subscription: pushSubscription };
  }
};
