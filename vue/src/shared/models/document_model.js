/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let DocumentModel;
import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';

export default DocumentModel = (function() {
  DocumentModel = class DocumentModel extends BaseModel {
    static initClass() {
      this.singular = 'document';
      this.plural = 'documents';
      this.indices = ['modelId', 'authorId'];
    }

    relationships() {
      this.belongsTo('author', {from: 'users', by: 'authorId'});
      return this.belongsTo('group');
    }

    model() {
      return this.recordStore[`${this.modelType.toLowerCase()}s`].find(this.modelId);
    }

    modelTitle() {
      switch (this.modelType) {
        case 'Group':      return this.model().name;
        case 'Discussion': return this.model().title;
        case 'Outcome':    return this.model().poll().title;
        case 'Comment':    return this.model().discussion().title;
        case 'Poll':       return this.model().title;
      }
    }

    authorName() {
      if (this.author()) { return this.author().nameWithTitle(this.model().group()); }
    }

    isAnImage() {
      return this.icon === 'image';
    }
  };
  DocumentModel.initClass();
  return DocumentModel;
})();
