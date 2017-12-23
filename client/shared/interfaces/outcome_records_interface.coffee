BaseRecordsInterface = require 'shared/interfaces/base_records_interface.coffee'
OutcomeModel         = require 'shared/models/outcome_model.coffee'

module.exports = class OutcomeRecordsInterface extends BaseRecordsInterface
  model: OutcomeModel
