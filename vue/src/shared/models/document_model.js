import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';

export default class DocumentModel extends BaseModel {
  static singular = 'document';
  static plural = 'documents';
  static indices = ['modelId', 'authorId'];

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
