import BaseModel from '@/shared/record_store/base_model';
import Records from '@/shared/services/records';

export default class TaskModel extends BaseModel {
  static singular = 'task';
  static plural = 'tasks';
  static indices = ['authorId'];

  relationships() {
    this.belongsToPolymorphic('record');
  }

  toggleDone() {
    if (this.done) {
      return Records.tasks.remote.postMember(this.id, 'mark_as_not_done');
    } else {
      return Records.tasks.remote.postMember(this.id, 'mark_as_done');
    }
  }
};
