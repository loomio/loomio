import BaseRecordsInterface from '@/record_store/base_records_interface';
import TagModel  from '@/models/tag_model';

export default class TagRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = TagModel;
    this.baseConstructor(recordStore);
  }
};
