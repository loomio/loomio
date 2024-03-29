import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import ContactMessageModel  from '@/shared/models/contact_message_model';

export default class ContactMessageRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = ContactMessageModel;
    this.baseConstructor(recordStore);
  }
}
