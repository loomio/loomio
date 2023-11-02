import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import PollOptionModel    from '@/shared/models/poll_option_model';

export default class PollOptionRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = PollOptionModel;
    this.baseConstructor(recordStore);
  }
};
