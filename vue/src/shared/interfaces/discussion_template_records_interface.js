/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let DiscussionTemplateRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import DiscussionTemplateModel  from '@/shared/models/discussion_template_model';

export default DiscussionTemplateRecordsInterface = (function() {
  DiscussionTemplateRecordsInterface = class DiscussionTemplateRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = DiscussionTemplateModel;
    }
  };
  DiscussionTemplateRecordsInterface.initClass();
  return DiscussionTemplateRecordsInterface;
})();