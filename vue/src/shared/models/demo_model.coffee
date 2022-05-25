import BaseModel        from '@/shared/record_store/base_model'

export default class DemoModel extends BaseModel
  @singular: 'template'
  @plural: 'templates'
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
    @belongsToPolymorphic 'record'
