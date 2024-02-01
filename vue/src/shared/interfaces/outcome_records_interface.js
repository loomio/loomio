import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import OutcomeModel         from '@/shared/models/outcome_model';

export default class OutcomeRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = OutcomeModel;
    this.baseConstructor(recordStore); 
  }
}
