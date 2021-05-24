import BaseModel from '@/shared/record_store/base_model.coffee'

export default class TaskModel extends BaseModel
  @singular: 'task'
  @plural: 'tasks'
  @uniqueIndices: ['id', 'authorId']
