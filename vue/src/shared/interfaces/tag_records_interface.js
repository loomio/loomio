/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let TagRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import TagModel  from '@/shared/models/tag_model';

export default TagRecordsInterface = (function() {
  TagRecordsInterface = class TagRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = TagModel;
    }
  };
  TagRecordsInterface.initClass();
  return TagRecordsInterface;
})();
