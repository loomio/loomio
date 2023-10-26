/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let ChatbotRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import ChatbotModel   from '@/shared/models/chatbot_model';

export default ChatbotRecordsInterface = (function() {
  ChatbotRecordsInterface = class ChatbotRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = ChatbotModel;
    }
  };
  ChatbotRecordsInterface.initClass();
  return ChatbotRecordsInterface;
})();
