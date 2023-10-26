/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let WebhookRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import WebhookModel   from '@/shared/models/webhook_model';

export default WebhookRecordsInterface = (function() {
  WebhookRecordsInterface = class WebhookRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = WebhookModel;
    }
  };
  WebhookRecordsInterface.initClass();
  return WebhookRecordsInterface;
})();
