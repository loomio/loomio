BaseRecordsInterface = require 'shared/record_store/base_records_interface'
GroupIdentityModel   = require 'shared/models/group_identity_model'

module.exports = class GroupIdentityRecordsInterface extends BaseRecordsInterface
  model: GroupIdentityModel
