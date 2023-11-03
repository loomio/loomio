import BaseRecordsInterface from '@/record_store/base_records_interface';
import ChatbotModel   from '@/models/chatbot_model';

export default class ChatbotRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = ChatbotModel;
    this.baseConstructor(recordStore);
  }
}
