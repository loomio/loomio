import Records            from '@/shared/services/records';
import Session            from '@/shared/services/session';
import ThreadFilter       from '@/shared/services/thread_filter';

export default new class InboxService {
  static filters = [
    'only_threads_in_my_groups',
    'show_unread',
    'show_recent',
    'hide_muted',
    'hide_dismissed'
  ];

  load(options) {
    if (options == null) { options = {}; }
    return Records.discussions.fetchInbox(options).then(() => { return this.loaded = true; });
  }

  unreadCount() {
    if (this.loaded) {
      return this.query().length;
    } else {
      return "...";
    }
  }

  query() { return ThreadFilter({filters: this.constructor.filters}); }
};
