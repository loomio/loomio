BaseRecordsInterface = require 'shared/record_store/base_records_interface'
SessionModel         = require 'shared/models/session_model'

module.exports = class SessionRecordsInterface extends BaseRecordsInterface
  model: SessionModel
