/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let DemoRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import DemoModel from '@/shared/models/demo_model';

export default DemoRecordsInterface = (function() {
  DemoRecordsInterface = class DemoRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = DemoModel;
    }
  };
  DemoRecordsInterface.initClass();
  return DemoRecordsInterface;
})();
