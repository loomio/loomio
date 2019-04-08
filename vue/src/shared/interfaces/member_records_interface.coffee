BaseRecordsInterface = require '@/shared/record_store/base_records_interface'
MemberModel          = require '@/shared/models/member_model'

export default class MemberRecordsInterface extends BaseRecordsInterface
  model: MemberModel
