import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';

export default class ChatbotModel extends BaseModel {
  static singular = 'chatbot';
  static plural = 'chatbots';

  defaultValues() {
    return {
      groupId: null,
      name: null,
      server: null,
      accessToken: null,
      eventKinds: [],
      kind: null,
      webhookKind: null,
      errors: {},
      notificationOnly: false
    };
  }

  relationships() {
    this.belongsTo('group');
  }
};
