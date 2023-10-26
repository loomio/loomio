/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let ChatbotModel;
import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';

export default ChatbotModel = (function() {
  ChatbotModel = class ChatbotModel extends BaseModel {
    static initClass() {
      this.singular = 'chatbot';
      this.plural = 'chatbots';
    }

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
      return this.belongsTo('group');
    }
  };
  ChatbotModel.initClass();
  return ChatbotModel;
})();
