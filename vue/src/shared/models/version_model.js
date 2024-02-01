import BaseModel from '@/shared/record_store/base_model';
import {filter, keys, includes} from 'lodash-es';

export default class VersionModel extends BaseModel {
  static singular = 'version';
  static plural = 'versions';
  static indices = ['discussionId'];

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
