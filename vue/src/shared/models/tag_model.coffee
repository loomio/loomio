import BaseModel            from '@/shared/record_store/base_model.coffee'

export default class TagModel extends BaseModel
  @singular: 'tag'
  @plural: 'tags'
  @uniqueIndices: ['id']
  @indices: ['groupId']
  @serializableAttributes: ['groupId', 'color', 'name']

  defaults: ->
    color: '#acb'

  relationships: ->
    @belongsTo 'group'
