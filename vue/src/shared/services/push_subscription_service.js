import AppConfig from '@/shared/services/app_config';
import RestfulClient from '@/shared/record_store/restful_client';

const client = new RestfulClient('push_subscriptions');

function applicationServerKey(value) {
  const padding = '='.repeat((4 - value.length % 4) % 4);
  const base64 = (value + padding).replace(/-/g, '+').replace(/_/g, '/');
  return Uint8Array.from(atob(base64), character => character.charCodeAt(0));
}

export default new class PushSubscriptionService {
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
    return navigator.serviceWorker.register('/service-worker.js');
  }

  async current() {
    if (!this.supported()) return null;
    const registration = await this.registration();
    return registration.pushManager.getSubscription();
  }

  async enabled() {
    return !!(await this.current());
  }

  async enable(name = null) {
    if (!this.supported()) throw new Error('push_not_supported');

    const permission = await Notification.requestPermission();
    if (permission !== 'granted') throw new Error('push_permission_denied');

    const registration = await this.registration();
    let subscription = await registration.pushManager.getSubscription();
    subscription ||= await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: applicationServerKey(AppConfig.vapidPublicKey)
    });

    const value = subscription.toJSON();
    await client.create({
      push_subscription: {
        endpoint: value.endpoint,
        p256dh_key: value.keys.p256dh,
        auth_key: value.keys.auth,
        expires_at: value.expirationTime ? new Date(value.expirationTime).toISOString() : null,
        name
      }
    });
    return subscription;
  }

  async disable() {
    if (!this.supported()) return;
    const subscription = await this.current();
    if (!subscription) return;

    try {
      await client.delete('', { endpoint: subscription.endpoint });
    } finally {
      await subscription.unsubscribe();
    }
  }

  async subscriptions() {
    if (!AppConfig.webPushEnabled) return [];
    const data = await client.get('');
    return data.push_subscriptions || [];
  }

  sendTest() {
    return client.post('send_test', {});
  }
};
