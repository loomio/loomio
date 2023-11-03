import BaseRecordsInterface from '@/record_store/base_records_interface';
import PollOptionModel    from '@/models/poll_option_model';

export default class PollOptionRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = PollOptionModel;
    this.baseConstructor(recordStore);
  }
};
