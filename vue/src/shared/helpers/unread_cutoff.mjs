import { subWeeks } from 'date-fns';

// Threads with lastActivityAt older than this window do not count toward
// unread badges or appear when filtering by unread, though they still display
// their unread styling when browsing all/recent threads.
export const UNREAD_RELEVANCY_WEEKS = 6;

export function unreadCutoffDate(now = new Date()) {
  return subWeeks(now, UNREAD_RELEVANCY_WEEKS);
}
