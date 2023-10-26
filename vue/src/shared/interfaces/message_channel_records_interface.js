/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let MessageChannelRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';

export default MessageChannelRecordsInterface = (function() {
  MessageChannelRecordsInterface = class MessageChannelRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.apiEndpoint = 'message_channel';
      this.prototype.model = {
        singular:    'message_channel',
        plural:      'message_channel'
      };
    }
  };
  MessageChannelRecordsInterface.initClass();
  return MessageChannelRecordsInterface;
})();
