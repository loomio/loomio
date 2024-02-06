import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import RecievedEmailModel from '@/shared/models/received_email_model';

export default class ReceivedEmailRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = RecievedEmailModel;
    this.baseConstructor(recordStore);
  }
}
