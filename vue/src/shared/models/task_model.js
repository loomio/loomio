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
    const previousDoneAt = this.doneAt;
    const action = previousDoneAt ? 'mark_as_not_done' : 'mark_as_done';
    this.doneAt = previousDoneAt ? null : new Date().toISOString();
    this.processing = true;
    return Records.tasks.remote.postMember(this.id, action)
      .catch(error => {
        this.doneAt = previousDoneAt;
        throw error;
      })
      .finally(() => { this.processing = false; });
  }
};
