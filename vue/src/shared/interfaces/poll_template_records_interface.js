import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import PollTemplateModel    from '@/shared/models/poll_template_model';

export default class PollTemplateRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = PollTemplateModel;
    this.baseConstructor(recordStore); 
  }

  fetchByGroupId(groupId) {
    return this.remote.fetch({params: {group_id: groupId}, exclude_types: 'group'});
  }

  findOrFetchByKeyOrId(keyOrId) {
    const record = this.find(keyOrId);
    if (record) {
      return Promise.resolve(record);
    } else {
      return this.remote.fetch({params: {key_or_id: keyOrId}}).then(() => {
        return this.find(keyOrId);
      });
    }
  }
};

