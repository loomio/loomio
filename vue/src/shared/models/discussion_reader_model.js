/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let DiscussionReaderModel;
import BaseModel       from '@/shared/record_store/base_model';
import AppConfig       from '@/shared/services/app_config';

export default DiscussionReaderModel = (function() {
  DiscussionReaderModel = class DiscussionReaderModel extends BaseModel {
    static initClass() {
      this.singular = 'discussionReader';
      this.plural = 'discussionReaders';
      this.indices = ['discussionId', 'userId'];
      this.uniqueIndices = ['id'];
    }

    defaultValues() {
      return {
        discussionId: null,
        userId: null
      };
    }

    relationships() {
      this.belongsTo('user', {from: 'users'});
      return this.belongsTo('discussion');
    }
  };
  DiscussionReaderModel.initClass();
  return DiscussionReaderModel;
})();
