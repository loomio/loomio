BaseModel = require 'shared/record_store/base_model'
AppConfig = require 'shared/services/app_config'

module.exports = class DocumentModel extends BaseModel
  @singular: 'document'
  @plural: 'documents'
  @indices: ['modelId', 'authorId']
  @serializableAttributes: AppConfig.permittedParams.document

  relationships: ->
    @belongsTo 'author', from: 'users', by: 'authorId'
    @belongsTo 'group'

  model: ->
    @recordStore["#{@modelType.toLowerCase()}s"].find(@modelId)

  modelTitle: ->
    switch @modelType
      when 'Group'      then @model().name
      when 'Discussion' then @model().title
      when 'Outcome'    then @model().poll().title
      when 'Comment'    then @model().discussion().title
      when 'Poll'       then @model().title

  authorName: ->
    @author().nameWithTitle(@model()) if @author()

  isAnImage: ->
    @icon == 'image'
