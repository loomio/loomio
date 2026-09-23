import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import TopicItemModel           from '@/shared/models/topic_item_model';

export default class TopicItemRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = TopicItemModel;
    this.baseConstructor(recordStore);
  }

  fetchByDiscussion(discussionKey, options) {
    if (options == null) { options = {}; }
    options['discussion_key'] = discussionKey;
    return this.fetch({
      params: options});
  }

};
