import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import VersionModel         from '@/shared/models/version_model';

export default class VersionRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = VersionModel;
    this.baseConstructor(recordStore);
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
