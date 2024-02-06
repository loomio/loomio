import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import RegistrationModel    from '@/shared/models/registration_model';

export default class RegistrationRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = RegistrationModel;
    this.baseConstructor(recordStore);
  }
}
