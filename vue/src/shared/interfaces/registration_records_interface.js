/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let RegistrationRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import RegistrationModel    from '@/shared/models/registration_model';

export default RegistrationRecordsInterface = (function() {
  RegistrationRecordsInterface = class RegistrationRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = RegistrationModel;
    }
  };
  RegistrationRecordsInterface.initClass();
  return RegistrationRecordsInterface;
})();
