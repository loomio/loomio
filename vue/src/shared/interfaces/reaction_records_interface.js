/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let ReactionRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import ReactionModel        from '@/shared/models/reaction_model';
import { debounce } from 'lodash';

export default ReactionRecordsInterface = (function() {
  ReactionRecordsInterface = class ReactionRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = ReactionModel;
    }
  };
  ReactionRecordsInterface.initClass();
  return ReactionRecordsInterface;
})();
