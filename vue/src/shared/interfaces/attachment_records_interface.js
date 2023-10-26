/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let AttachmentRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import AttachmentModel        from '@/shared/models/attachment_model';

export default AttachmentRecordsInterface = (function() {
  AttachmentRecordsInterface = class AttachmentRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = AttachmentModel;
    }
  };
  AttachmentRecordsInterface.initClass();
  return AttachmentRecordsInterface;
})();
