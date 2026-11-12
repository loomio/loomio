import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import { usePendingPolls } from '@/composables/usePendingPolls';
import { useCurrentUserNotifications } from '@/composables/useCurrentUserNotifications';

export const dashboardParams = {offset: 0, limit: 30, order: 'id'};

// Warm the dashboard and share the pending-vote load with navigation counts.
// Fetching notifications must not mark them viewed;
// that belongs to opening the notifications page or reading the actual items.
export function prefetchNavigation(path) {
  if (!Session.isSignedIn()) return Promise.resolve([]);
  return Promise.allSettled([
    ...(path === '/dashboard' ? [] : [Records.topics.fetch({params: dashboardParams})]),
    usePendingPolls().loadPendingPolls(),
    useCurrentUserNotifications().loadNotifications(),
    import('@/components/notifications/page.vue'),
    import('@/components/dashboard/polls_to_vote_on_page.vue')
  ]);
}
