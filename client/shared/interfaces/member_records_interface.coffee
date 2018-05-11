BaseRecordsInterface = require 'shared/record_store/base_records_interface'
MemberModel          = require 'shared/models/member_model'

module.exports = class MemberRecordsInterface extends BaseRecordsInterface
  model: MemberModel
