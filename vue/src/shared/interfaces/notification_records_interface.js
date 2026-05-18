import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import NotificationModel    from '@/shared/models/notification_model';

const KINDS_THAT_GRANT_GROUP_ACCESS = ['user_added_to_group'];

export default class NotificationRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = NotificationModel;
    this.baseConstructor(recordStore);
  }

  importRecord(attributes) {
    const isNew = attributes.id != null && this.find(attributes.id) == null;
    const record = super.importRecord(attributes);
    if (isNew && KINDS_THAT_GRANT_GROUP_ACCESS.includes(attributes.kind)) {
      this.recordStore.users.fetchGroups();
    }
    return record;
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
};
