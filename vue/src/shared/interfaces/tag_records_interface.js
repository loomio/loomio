import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import TagModel  from '@/shared/models/tag_model';

export default class TagRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = TagModel;
    this.baseConstructor(recordStore);
  }
};
