BaseRecordsInterface = require 'shared/interfaces/base_records_interface.coffee'
PollOptionModel    = require 'shared/models/poll_option_model.coffee'

module.exports = class PollOptionRecordsInterface extends BaseRecordsInterface
  model: PollOptionModel
