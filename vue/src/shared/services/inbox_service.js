/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let InboxService;
import Records            from '@/shared/services/records';
import Session            from '@/shared/services/session';
import ThreadFilter       from '@/shared/services/thread_filter';

export default new ((InboxService = (function() {
  InboxService = class InboxService {
    static initClass() {
  
      this.prototype.filters = [
        'only_threads_in_my_groups',
        'show_unread',
        'show_recent',
        'hide_muted',
        'hide_dismissed'
      ];
      
    }

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

    query() { return ThreadFilter({filters: this.filters}); }
  };
  InboxService.initClass();
  return InboxService;
})()));
