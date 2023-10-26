/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let NotificationRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import NotificationModel    from '@/shared/models/notification_model';

export default NotificationRecordsInterface = (function() {
  NotificationRecordsInterface = class NotificationRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = NotificationModel;
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
  NotificationRecordsInterface.initClass();
  return NotificationRecordsInterface;
})();
