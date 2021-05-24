import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import TaskModel  from '@/shared/models/task_model'

export default class TaskRecordsInterface extends BaseRecordsInterface
  model: TaskModel
