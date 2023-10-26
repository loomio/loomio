/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let TaskRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import TaskModel  from '@/shared/models/task_model';

export default TaskRecordsInterface = (function() {
  TaskRecordsInterface = class TaskRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = TaskModel;
    }
  };
  TaskRecordsInterface.initClass();
  return TaskRecordsInterface;
})();
