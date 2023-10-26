/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let RegistrationModel;
import BaseModel from '@/shared/record_store/base_model';

export default RegistrationModel = (function() {
  RegistrationModel = class RegistrationModel extends BaseModel {
    static initClass() {
      this.singular = 'registration';
      this.plural = 'registrations';
      this.serializableAttributes = ['name', 'email', 'password', 'passwordConfirmation', 'recaptcha', 'legalAccepted', 'emailNewsletter'];
      this.serializationRoot = 'user';
    }
  };
  RegistrationModel.initClass();
  return RegistrationModel;
})();
