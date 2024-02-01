import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import DiscussionReaderModel from '@/shared/models/discussion_reader_model';

export default class DiscussionReaderRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = DiscussionReaderModel;
    this.baseConstructor(recordStore);
  }
}
