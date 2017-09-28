angular.module('loomioApp').factory 'DocumentModel', (BaseModel, AppConfig) ->
  class DocumentModel extends BaseModel
    @singular: 'document'
    @plural: 'documents'
    @indices: ['modelId']
    @serializableAttributes: AppConfig.permittedParams.document

    relationships: ->
      @belongsTo 'author', from: 'users', by: 'authorId'

    model: ->
      @recordStore["#{@modelType.toLowerCase()}s"].find(@modelId)
