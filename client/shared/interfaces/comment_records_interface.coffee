BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
CommentModel         = require 'shared/models/comment_model.coffee'

module.exports = class CommentRecordsInterface extends BaseRecordsInterface
  model: CommentModel

  like: (user, comment, success) ->
    @remote.postMember comment.id, "like"

  unlike: (user, comment, success) ->
    @remote.postMember comment.id, "unlike"
