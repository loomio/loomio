BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
VersionModel         = require 'shared/models/version_model.coffee'

module.exports = class VersionRecordsInterface extends BaseRecordsInterface
  model: VersionModel

  fetchByDiscussion: (discussionKey, options = {}) ->
    @fetch
      params:
        model: 'discussion'
        discussion_id: discussionKey

  fetchByComment: (commentId, options = {}) ->
    @fetch
      params:
        model: 'comment'
        comment_id: commentId
