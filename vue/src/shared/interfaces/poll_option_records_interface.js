/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let PollOptionRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import PollOptionModel    from '@/shared/models/poll_option_model';

export default PollOptionRecordsInterface = (function() {
  PollOptionRecordsInterface = class PollOptionRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = PollOptionModel;
    }
  };
  PollOptionRecordsInterface.initClass();
  return PollOptionRecordsInterface;
})();
