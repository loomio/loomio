/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let DocumentRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import DocumentModel        from '@/shared/models/document_model';
import {flatten, capitalize, includes} from 'lodash';

export default DocumentRecordsInterface = (function() {
  DocumentRecordsInterface = class DocumentRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = DocumentModel;
    }

    fetchByModel(model) {
      return this.fetch({
        params: {
          [`${model.constructor.singular}_id`]: model.id
        }
      });
    }

    fetchByDiscussion(discussion) {
      return this.fetch({
        path: 'for_discussion',
        params: {
          discussion_key: discussion.key
        }
      });
    }
  };
  DocumentRecordsInterface.initClass();
  return DocumentRecordsInterface;
})();
