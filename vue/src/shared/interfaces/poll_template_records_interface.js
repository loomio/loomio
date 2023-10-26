/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let PollTemplateRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import PollTemplateModel    from '@/shared/models/poll_template_model';

export default PollTemplateRecordsInterface = (function() {
  PollTemplateRecordsInterface = class PollTemplateRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = PollTemplateModel;
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
  PollTemplateRecordsInterface.initClass();
  return PollTemplateRecordsInterface;
})();

