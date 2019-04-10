Records              = require 'shared/services/records.coffee'
BaseModel            = require 'shared/record_store/base_model.coffee'
BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'

TagModel = class TagModel extends BaseModel
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
    _.head(@recordStore.discussionTags.find(tagId: @id, discussionId: discussionId)) or
    @recordStore.discussionTags.build(tagId: @id, discussionId: discussionId)

TagRecordsInterface = class TagRecordsInterface extends BaseRecordsInterface
  model: TagModel

  fetchByGroup: (group) ->
    @fetch
      params:
        group_id: group.id

Records.addRecordsInterface(TagRecordsInterface)
