Records              = require 'shared/services/records.coffee'
BaseModel            = require 'shared/record_store/base_model.coffee'
BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'

DiscussionTagModel = class DiscussionTagModel extends BaseModel
  @singular: 'discussionTag'
  @plural: 'discussionTags'
  @uniqueIndices: ['id']
  @indices: ['discussionId']

  relationships: ->
    @belongsTo 'discussion'
    @belongsTo 'tag'

  toggle: ->
    if @isNew() then @save() else @destroy()

DiscussionTagRecordsInterface = class DiscussionTagRecordsInterface extends BaseRecordsInterface
  model: DiscussionTagModel

Records.addRecordsInterface(DiscussionTagRecordsInterface)
