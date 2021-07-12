import BaseModel from '@/shared/record_store/base_model.coffee'

export default class TaskModel extends BaseModel
  @singular: 'task'
  @plural: 'tasks'
  @indices: ['authorId']

  relationships: ->
    @belongsToPolymorphic('record')

  toggleDone: ->
    if @done
      @remote.postMember(@id, 'mark_as_not_done')
    else
      @remote.postMember(@id, 'mark_as_done')
