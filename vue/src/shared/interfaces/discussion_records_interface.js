import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import DiscussionModel      from '@/shared/models/discussion_model';
import Session              from '@/shared/services/session';
import EventBus             from '@/shared/services/event_bus';
import NullDiscussionModel  from '@/shared/models/null_discussion_model';
import { includes } from 'lodash-es';

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
