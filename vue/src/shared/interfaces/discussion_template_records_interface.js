import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import DiscussionTemplateModel  from '@/shared/models/discussion_template_model';

export default class DiscussionTemplateRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = DiscussionTemplateModel;
    this.baseConstructor(recordStore);
  }

  findOrFetchByKey(key, groupId) {
    const record = this.find(key);
    if (record) {
      return Promise.resolve(record);
    } else {
      return this.remote.fetch({params: {key: key, group_id: groupId}}).then(() => {
        return this.find(key);
      });
    }
  }
}
