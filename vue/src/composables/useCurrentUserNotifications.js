import Records from '@/shared/services/records';

// Share the initial load across components. Explicit refreshes still call
// fetchNotifications directly so opening notifications or receiving a push gets fresh data.
let notificationsPromise = null;

export function useCurrentUserNotifications() {
  function loadNotifications() {
    notificationsPromise ||= Records.notifications.fetchNotifications();
    return notificationsPromise;
  }

  return { loadNotifications };
}
