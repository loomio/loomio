import BaseModel            from '@/shared/record_store/base_model.coffee'
import { head } from 'lodash'

export default class TagModel extends BaseModel
  @singular: 'tag'
  @plural: 'tags'
  @uniqueIndices: ['id']
  @indices: ['groupId']
  @serializableAttributes: ['groupId', 'color', 'name']

  relationships: ->
    @belongsTo 'group'

  toggle: (discussionId) ->
    @discussionTagFor(discussionId).toggle()
    false

  discussionTagFor: (discussionId) ->
    head(@recordStore.discussionTags.find(tagId: @id, discussionId: discussionId)) or
    @recordStore.discussionTags.build(tagId: @id, discussionId: discussionId)
