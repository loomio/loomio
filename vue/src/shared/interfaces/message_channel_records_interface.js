import BaseRecordsInterface from '@/shared/record_store/base_records_interface';

export default class MessageChannelRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.apiEndpoint = 'message_channel';
    this.model = {
      singular:    'message_channel',
      plural:      'message_channel'
    };
    this.baseConstructor(recordStore); 
  };
}
