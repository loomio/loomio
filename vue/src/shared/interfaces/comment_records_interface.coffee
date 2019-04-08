import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import CommentModel         from '@/shared/models/comment_model'

export default class CommentRecordsInterface extends BaseRecordsInterface
  model: CommentModel

  like: (user, comment, success) ->
    @remote.postMember comment.id, "like"

  unlike: (user, comment, success) ->
    @remote.postMember comment.id, "unlike"
