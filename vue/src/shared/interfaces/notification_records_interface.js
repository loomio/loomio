import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import NotificationModel    from '@/shared/models/notification_model';

export default class NotificationRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = NotificationModel;
    this.baseConstructor(recordStore);
  }

  fetchNotifications(query, options) {
    if (options == null) { options = {}; }
    return this.fetch({
      params: options});
  }

  viewed() {
    let any = false;
    this.collection.find({viewed: { $ne: true}}).forEach(n => {
      any = true;
      return n.update({viewed: true});
    });

    if (any) { return this.remote.post('viewed'); }
  }

  unreadForTopicItem(topicId, sequenceId) {
    return this.find({topicId, sequenceId, viewed: {$ne: true}});
  }

  viewedForTopicItem(topicId, sequenceId) {
    this.unreadForTopicItem(topicId, sequenceId).forEach(n => {
      n.update({viewed: true});
    });
  }
};
