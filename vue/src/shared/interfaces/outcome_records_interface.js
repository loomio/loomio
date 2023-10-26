/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let OutcomeRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import OutcomeModel         from '@/shared/models/outcome_model';

export default OutcomeRecordsInterface = (function() {
  OutcomeRecordsInterface = class OutcomeRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = OutcomeModel;
    }
  };
  OutcomeRecordsInterface.initClass();
  return OutcomeRecordsInterface;
})();
