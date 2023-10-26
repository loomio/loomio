/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let ContactRequestRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import ContactRequestModel  from '@/shared/models/contact_request_model';

export default ContactRequestRecordsInterface = (function() {
  ContactRequestRecordsInterface = class ContactRequestRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = ContactRequestModel;
    }
  };
  ContactRequestRecordsInterface.initClass();
  return ContactRequestRecordsInterface;
})();
