self.addEventListener('install', () => {
  // Updated workers intentionally wait until the user accepts the reload notice.
});

self.addEventListener('activate', event => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('message', event => {
  if (event.data?.type === 'SKIP_WAITING') {
    event.waitUntil(self.skipWaiting());
  }
  if (event.data?.type === 'UNSUBSCRIBE_PUSH') {
    const unsubscribe = self.registration.pushManager
      ? self.registration.pushManager.getSubscription().then(subscription => subscription?.unsubscribe())
      : Promise.resolve();
    event.waitUntil(unsubscribe);
  }
});

self.addEventListener('push', event => {
  if (!event.data) return;

  let payload;
  try {
    payload = event.data.json();
  } catch (_error) {
    return;
  }

  event.waitUntil(self.registration.showNotification(payload.title, {
    body: payload.body,
    icon: payload.icon,
    badge: payload.badge,
    tag: payload.tag,
    data: payload.data || {}
  }));
});

self.addEventListener('notificationclick', event => {
  event.notification.close();

  const requestedUrl = new URL(event.notification.data?.url || '/', self.location.origin);
  const targetUrl = requestedUrl.origin === self.location.origin ? requestedUrl.href : self.location.origin;

  event.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(clients => {
    const existing = clients.find(client => client.url === targetUrl);
    if (existing) return existing.focus();
    return self.clients.openWindow(targetUrl);
  }));
});
