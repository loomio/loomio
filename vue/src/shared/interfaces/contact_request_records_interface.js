import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import ContactRequestModel  from '@/shared/models/contact_request_model';

export default class ContactRequestRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = ContactRequestModel;
    this.baseConstructor(recordStore);
  }
};
