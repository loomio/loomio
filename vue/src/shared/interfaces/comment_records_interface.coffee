import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import CommentModel         from '@/shared/models/comment_model'

export default class CommentRecordsInterface extends BaseRecordsInterface
  model: CommentModel
