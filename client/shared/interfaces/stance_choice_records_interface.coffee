BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
StanceChoiceModel    = require 'shared/models/stance_choice_model.coffee'

module.exports = class StanceChoiceRecordsInterface extends BaseRecordsInterface
  model: StanceChoiceModel
