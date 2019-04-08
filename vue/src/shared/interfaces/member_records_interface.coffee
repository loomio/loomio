import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import MemberModel          from '@/shared/models/member_model'

export default class MemberRecordsInterface extends BaseRecordsInterface
  model: MemberModel
