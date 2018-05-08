BaseRecordsInterface = require 'shared/record_store/base_records_interface'
PollOptionModel    = require 'shared/models/poll_option_model'

module.exports = class PollOptionRecordsInterface extends BaseRecordsInterface
  model: PollOptionModel
