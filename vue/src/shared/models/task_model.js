import BaseModel from '@/shared/record_store/base_model';

export default class TaskModel extends BaseModel {
  static singular = 'task';
  static plural = 'tasks';
  static indices = ['authorId'];

  relationships() {
    this.belongsToPolymorphic('record');
  }

  toggleDone() {
    if (this.done) {
      return this.remote.postMember(this.id, 'mark_as_not_done');
    } else {
      return this.remote.postMember(this.id, 'mark_as_done');
    }
  }
};
