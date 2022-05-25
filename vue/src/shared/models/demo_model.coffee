import BaseModel        from '@/shared/record_store/base_model'

export default class DemoModel extends BaseModel
  @singular: 'demo'
  @plural: 'demos'
  @uniqueIndices: ['id']
  @indices: ['groupId', 'authorId']

  defaultValues: ->
    id: null
    name: null
    description: null
    groupId: null
    demoHandle: null

  relationships: ->
    @belongsTo 'group'
    @belongsTo 'author', from: 'users'
