import Records from '@/shared/services/records';
import Session from '@/shared/services/session';

export const dashboardParams = {offset: 0, limit: 30, order: 'id', exclude_types: 'reaction'};
export const votePollParams = {offset: 0, limit: 25, order: 'id', exclude_types: 'group reaction', status: 'recent'};

// Warm the first page only. Fetching notifications must not mark them viewed;
// that belongs to opening the notifications page or reading the actual items.
export function prefetchNavigation() {
  if (!Session.isSignedIn()) return Promise.resolve([]);
  return Promise.allSettled([
    Records.topics.fetch({params: dashboardParams}),
    Records.polls.fetch({params: votePollParams}),
    Records.stances.fetch({path: 'my_stances'}),
    Records.notifications.fetchNotifications(),
    import('@/components/notifications/page.vue'),
    import('@/components/dashboard/polls_to_vote_on_page.vue')
  ]);
}
