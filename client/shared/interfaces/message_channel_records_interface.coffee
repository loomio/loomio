BaseRecordsInterface = require 'shared/record_store/base_records_interface'

module.exports = class MessageChannelRecordsInterface extends BaseRecordsInterface
  model:
    singular:    'message_channel'
    plural:      'message_channel'
    apiEndpoint: 'message_channel'
