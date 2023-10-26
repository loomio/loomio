/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let CommentRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import CommentModel         from '@/shared/models/comment_model';

export default CommentRecordsInterface = (function() {
  CommentRecordsInterface = class CommentRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = CommentModel;
    }
  };
  CommentRecordsInterface.initClass();
  return CommentRecordsInterface;
})();
