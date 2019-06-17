import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import DiscussionTagModel  from '@/shared/models/discussion_tag_model'

export default class DiscussionTagRecordsInterface extends BaseRecordsInterface
  model: DiscussionTagModel
