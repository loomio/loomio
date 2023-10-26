/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let VersionRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import VersionModel         from '@/shared/models/version_model';

export default VersionRecordsInterface = (function() {
  VersionRecordsInterface = class VersionRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = VersionModel;
    }

    // fetchByDiscussion: (discussionKey, options = {}) ->
    //   @fetch
    //     params:
    //       model: 'discussion'
    //       discussion_id: discussionKey

    // fetchByComment: (commentId, options = {}) ->
    //   @fetch
    //     params:
    //       model: 'comment'
    //       comment_id: commentId

    fetchVersion(model, index,  options) {
      if (options == null) { options = {}; }
      const model_type = model.constructor.singular;
      return this.fetch({
        params: {
          [`${model_type}_id`]:model.id,
          index
        }
      });
    }
  };
  VersionRecordsInterface.initClass();
  return VersionRecordsInterface;
})();
