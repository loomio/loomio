/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let ContactMessageModel;
import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';

export default ContactMessageModel = (function() {
  ContactMessageModel = class ContactMessageModel extends BaseModel {
    static initClass() {
      this.singular = 'contactMessage';
      this.plural = 'contactMessages';
      this.serializableAttributes = ["email", "subject", "user_id", "message", "name"];
    }
  };
  ContactMessageModel.initClass();
  return ContactMessageModel;
})();
