import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import PendingEmailModel from '@/shared/models/pending_email_model';

export default class PendingEmailRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = PendingEmailModel;
    this.baseConstructor(recordStore);
  }
}
