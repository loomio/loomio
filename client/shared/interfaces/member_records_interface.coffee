BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
MemberModel          = require 'shared/models/member_model.coffee'

module.exports = class MemberRecordsInterface extends BaseRecordsInterface
  model: MemberModel
