import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import VersionModel         from '@/shared/models/version_model'

export default class VersionRecordsInterface extends BaseRecordsInterface
  model: VersionModel

  # fetchByDiscussion: (discussionKey, options = {}) ->
  #   @fetch
  #     params:
  #       model: 'discussion'
  #       discussion_id: discussionKey

  # fetchByComment: (commentId, options = {}) ->
  #   @fetch
  #     params:
  #       model: 'comment'
  #       comment_id: commentId

  fetchVersion: (model, index,  options = {}) ->
    model_type = model.constructor.singular
    @fetch
      params:
        "#{model_type}_id":model.id
        index: index
