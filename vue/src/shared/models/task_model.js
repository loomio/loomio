/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let TaskModel;
import BaseModel from '@/shared/record_store/base_model';

export default TaskModel = (function() {
  TaskModel = class TaskModel extends BaseModel {
    static initClass() {
      this.singular = 'task';
      this.plural = 'tasks';
      this.indices = ['authorId'];
    }

    relationships() {
      return this.belongsToPolymorphic('record');
    }

    toggleDone() {
      if (this.done) {
        return this.remote.postMember(this.id, 'mark_as_not_done');
      } else {
        return this.remote.postMember(this.id, 'mark_as_done');
      }
    }
  };
  TaskModel.initClass();
  return TaskModel;
})();
