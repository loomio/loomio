angular.module('loomioApp').factory 'DocumentModel', (BaseModel, AppConfig) ->
  class DocumentModel extends BaseModel
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
      @author().name if @author()

    isAnImage: ->
      @icon == 'image'
