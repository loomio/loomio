import BaseRecordsInterface from '@/record_store/base_records_interface';
import StanceModel          from '@/models/stance_model';

export default class StanceRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = StanceModel;
    this.baseConstructor(recordStore);
  }
};
