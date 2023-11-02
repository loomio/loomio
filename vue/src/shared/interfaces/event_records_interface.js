import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import EventModel           from '@/shared/models/event_model';

export default class EventRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = EventModel;
    this.baseConstructor(recordStore);
  }

  fetchByDiscussion(discussionKey, options) {
    if (options == null) { options = {}; }
    options['discussion_key'] = discussionKey;
    return this.fetch({
      params: options});
  }

  findByDiscussionAndSequenceId(discussion, sequenceId) {
    return this.collection.chain()
               .find({discussionId: discussion.id})
               .find({sequenceId})
               .data()[0];
  }
};
