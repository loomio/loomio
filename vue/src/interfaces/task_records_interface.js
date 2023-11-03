import BaseRecordsInterface from '@/record_store/base_records_interface';
import TaskModel  from '@/models/task_model';

export default class TaskRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = TaskModel;
    this.baseConstructor(recordStore);
  }
}
