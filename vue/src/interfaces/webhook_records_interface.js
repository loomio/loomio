import BaseRecordsInterface from '@/record_store/base_records_interface';
import WebhookModel   from '@/models/webhook_model';

export default class WebhookRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = WebhookModel;
    this.baseConstructor(recordStore);
  }
};
