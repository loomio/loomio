import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import ChatbotModel   from '@/shared/models/chatbot_model';

export default class ChatbotRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = ChatbotModel;
    this.baseConstructor(recordStore);
  }
}
