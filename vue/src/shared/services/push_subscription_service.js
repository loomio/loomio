import AppConfig from '@/shared/services/app_config';
import RestfulClient from '@/shared/record_store/restful_client';
import PwaService from '@/shared/services/pwa_service';

const client = new RestfulClient('push_subscriptions');

function applicationServerKey(value) {
  const padding = '='.repeat((4 - value.length % 4) % 4);
  const base64 = (value + padding).replace(/-/g, '+').replace(/_/g, '/');
  return Uint8Array.from(atob(base64), character => character.charCodeAt(0));
}

export default new class PushSubscriptionService {
  mutationPromise = Promise.resolve();

  supported() {
    return AppConfig.webPushEnabled &&
      window.isSecureContext &&
      'Notification' in window &&
      'serviceWorker' in navigator &&
      'PushManager' in window;
  }

  permission() {
    return 'Notification' in window ? Notification.permission : 'unsupported';
  }

  async registration() {
    return PwaService.registration();
  }

  async current() {
    if (!this.supported()) return null;
    const registration = await this.registration();
    return registration?.pushManager.getSubscription() || null;
  }

  async enabled() {
    return !!(await this.current());
  }

  enable(name = null) {
    return this.enqueueMutation(async () => {
      if (!this.supported()) throw new Error('push_not_supported');

      const permission = await Notification.requestPermission();
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
      const subscription = await this.current();
      if (!subscription) return null;

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
      const subscription = await this.current();
      if (!subscription) return;

      try {
        await client.delete('', { endpoint: subscription.endpoint });
      } finally {
        await subscription.unsubscribe();
      }
    });
  }

  async disableBrowser() {
    PwaService.requestPushUnsubscribe();
    if (!this.supported()) return;
    const subscription = await this.current();
    if (subscription) await subscription.unsubscribe();
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
