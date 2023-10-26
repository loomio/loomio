/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let EventRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import EventModel           from '@/shared/models/event_model';

export default EventRecordsInterface = (function() {
  EventRecordsInterface = class EventRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = EventModel;
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
  EventRecordsInterface.initClass();
  return EventRecordsInterface; // so, turns out finding by multiple parameters doesn't actually work..
})();
