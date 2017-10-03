angular.module('loomioApp').factory 'DocumentModel', (BaseModel, AppConfig) ->
  class DocumentModel extends BaseModel
    @singular: 'document'
    @plural: 'documents'
    @indices: ['modelId', 'authorId']
    @serializableAttributes: AppConfig.permittedParams.document

    relationships: ->
      @belongsTo 'author', from: 'users', by: 'authorId'

    model: ->
      @recordStore["#{@modelType.toLowerCase()}s"].find(@modelId)

    authorName: ->
      @author().name if @author()

    isAnImage: ->
      @doctype == 'image'

    discussionTitle: ->
      model().discussion().title unless @modelType == 'Group'
