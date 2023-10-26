/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let ContactRequestModel;
import BaseModel from '@/shared/record_store/base_model';

export default ContactRequestModel = (function() {
  ContactRequestModel = class ContactRequestModel extends BaseModel {
    static initClass() {
      this.singular = 'contactRequest';
      this.plural = 'contactRequests';
    }

    defaultValues() {
      return {message: ''};
    }
  };
  ContactRequestModel.initClass();
  return ContactRequestModel;
})();
