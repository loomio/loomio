BaseRecordsInterface = require 'shared/record_store/base_records_interface'
OutcomeModel         = require 'shared/models/outcome_model'

module.exports = class OutcomeRecordsInterface extends BaseRecordsInterface
  model: OutcomeModel
