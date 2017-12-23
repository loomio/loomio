BaseRecordsInterface = require 'shared/interfaces/base_records_interface.coffee'
GroupIdentityModel   = require 'shared/models/group_identity_model.coffee'

module.exports = class GroupIdentityRecordsInterface extends BaseRecordsInterface
  model: GroupIdentityModel
