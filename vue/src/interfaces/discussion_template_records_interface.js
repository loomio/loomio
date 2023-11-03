import BaseRecordsInterface from '@/record_store/base_records_interface';
import DiscussionTemplateModel  from '@/models/discussion_template_model';

export default class DiscussionTemplateRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = DiscussionTemplateModel;
    this.baseConstructor(recordStore);
  }
}
