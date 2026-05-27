import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import TopicModel from '@/shared/models/topic_model';

export default class TopicRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = TopicModel;
    this.baseConstructor(recordStore);
  }
};
