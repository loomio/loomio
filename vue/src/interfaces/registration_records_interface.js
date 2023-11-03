import BaseRecordsInterface from '@/record_store/base_records_interface';
import RegistrationModel    from '@/models/registration_model';

export default class RegistrationRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = RegistrationModel;
    this.baseConstructor(recordStore);
  }
}
