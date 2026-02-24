import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import TopicReaderModel from '@/shared/models/topic_reader_model';

export default class TopicReaderRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = TopicReaderModel;
    this.baseConstructor(recordStore);
  }
}
