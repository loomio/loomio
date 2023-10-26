/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let VersionModel;
import BaseModel from '@/shared/record_store/base_model';
import {filter, keys, includes} from 'lodash';

export default VersionModel = (function() {
  VersionModel = class VersionModel extends BaseModel {
    static initClass() {
      this.singular = 'version';
      this.plural = 'versions';
      this.indices = ['discussionId'];
    }

    relationships() {
      this.belongsTo('discussion');
      this.belongsTo('comment');
      this.belongsTo('poll');
      return this.belongsTo('author', {from: 'users', by: 'whodunnit'});
    }

    editedAttributeNames() {
      return filter(keys(this.changes).sort(), key => includes(['title', 'name', 'description', 'closing_at', 'private', 'document_ids'], key));
    }

    attributeEdited(name) {
       return includes(keys(this.changes), name);
     }

    authorName() {
      if (this.author()) { return this.author().nameWithTitle(this.model().group()); }
    }

    model() {
      return this.recordStore[`${this.itemType.toLowerCase()}s`].find(this.itemId);
    }

    isCurrent() {
      return this.index === (this.model().versionsCount - 1);
    }

    isOriginal() {
      return this.index === 0;
    }

    authorOrEditorName() {
      if (this.isOriginal()) {
        return this.model().authorName();
      } else {
        return this.authorName();
      }
    }
  };
  VersionModel.initClass();
  return VersionModel;
})();
