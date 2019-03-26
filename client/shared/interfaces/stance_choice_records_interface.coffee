BaseRecordsInterface = require 'shared/record_store/base_records_interface'
StanceChoiceModel    = require 'shared/models/stance_choice_model'

module.exports = class StanceChoiceRecordsInterface extends BaseRecordsInterface
  model: StanceChoiceModel
