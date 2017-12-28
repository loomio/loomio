BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
PollOptionModel    = require 'shared/models/poll_option_model.coffee'

module.exports = class PollOptionRecordsInterface extends BaseRecordsInterface
  model: PollOptionModel
