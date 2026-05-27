import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import DiscussionModel      from '@/shared/models/discussion_model';
import NullDiscussionModel  from '@/shared/models/null_discussion_model';

export default class DiscussionRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = DiscussionModel;
    this.baseConstructor(recordStore);
  }

  nullModel() { return new NullDiscussionModel(); }
};
