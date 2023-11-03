import BaseRecordsInterface from '@/record_store/base_records_interface';
import ContactMessageModel  from '@/models/contact_message_model';

export default class ContactMessageRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = ContactMessageModel;
    this.baseConstructor(recordStore);
  }
}
