import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import StanceModel          from '@/shared/models/stance_model';

export default class StanceRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = StanceModel;
    this.baseConstructor(recordStore);
  }
};
