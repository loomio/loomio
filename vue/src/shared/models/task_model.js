import BaseModel from '@/shared/record_store/base_model';
import Records from '@/shared/services/records';

export default class TaskModel extends BaseModel {
  static singular = 'task';
  static plural = 'tasks';
  static indices = ['authorId'];

  relationships() {
    this.belongsToPolymorphic('record');
    return this.belongsTo('author', {from: 'users'});
  }

  toggleDone() {
    this.processing = true
    if (this.done) {
      return Records.tasks.remote.postMember(this.id, 'mark_as_not_done').finally(() => this.processing = false);
    } else {
      return Records.tasks.remote.postMember(this.id, 'mark_as_done').finally(() => this.processing = false);
    }
  }

  toggleHidden() {
    if (this.hidden) {
      return this.remote.postMember(this.id, 'mark_as_not_hidden');
    } else {
      return this.remote.postMember(this.id, 'mark_as_hidden');
    }
  }


};
