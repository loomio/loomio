BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
SessionModel         = require 'shared/models/session_model.coffee'

module.exports = class SessionRecordsInterface extends BaseRecordsInterface
  model: SessionModel
