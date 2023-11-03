import BaseRecordsInterface from '@/record_store/base_records_interface';
import DiscussionModel      from '@/models/discussion_model';
import Session              from '@/services/session';
import EventBus             from '@/services/event_bus';
import NullDiscussionModel  from '@/models/null_discussion_model';
import { includes } from 'lodash';

export default class DiscussionRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = DiscussionModel;
    this.baseConstructor(recordStore);
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
