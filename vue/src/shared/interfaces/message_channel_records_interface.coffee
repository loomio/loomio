import BaseRecordsInterface from '@/shared/record_store/base_records_interface'

export default class MessageChannelRecordsInterface extends BaseRecordsInterface
  apiEndpoint: 'message_channel'
  model:
    singular:    'message_channel'
    plural:      'message_channel'
