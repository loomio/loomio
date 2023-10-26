/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let ContactMessageRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import ContactMessageModel  from '@/shared/models/contact_message_model';

export default ContactMessageRecordsInterface = (function() {
  ContactMessageRecordsInterface = class ContactMessageRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = ContactMessageModel;
    }
  };
  ContactMessageRecordsInterface.initClass();
  return ContactMessageRecordsInterface;
})();
