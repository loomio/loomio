/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let DiscussionRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import DiscussionModel      from '@/shared/models/discussion_model';
import Session              from '@/shared/services/session';
import EventBus             from '@/shared/services/event_bus';
import NullDiscussionModel  from '@/shared/models/null_discussion_model';
import { includes } from 'lodash';

export default DiscussionRecordsInterface = (function() {
  DiscussionRecordsInterface = class DiscussionRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = DiscussionModel;
    }

    nullModel() { return new NullDiscussionModel(); }

    search(groupKey, fragment, options) {
      if (options == null) { options = {}; }
      options.group_id = groupKey;
      options.q = fragment;
      return this.fetch({
        path: 'search',
        params: options
      });
    }

    // fetchByGroup: (groupKey, options = {}) ->
    //   options['group_id'] = groupKey
    //   @fetch
    //     params: options
    //
    fetchInbox(options) {
      if (options == null) { options = {}; }
      return this.fetch({
        path: 'dashboard',
        params: {
          exclude_types: 'group',
          per: 50
        }
      });
    }
  };
  DiscussionRecordsInterface.initClass();
  return DiscussionRecordsInterface;
})();
