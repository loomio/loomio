angular.module('loomioApp').factory 'HasDocuments', ->
  new class HasDocuments
    apply: (model) ->
      model.newDocumentIds = model.newDocumentIds or []

      model.documents = ->
        model.recordStore.documents.find(modelId: model.id, modelType: _.capitalize(model.constructor.singular))

      model.newDocuments = ->
        model.recordStore.documents.find(model.newDocumentIds)

      model.newAndPersistedDocuments = ->
        model.documents().concat model.newDocuments()

      model.hasDocuments = ->
        model.newAndPersistedDocuments().length > 0

      model.serializer = ->
        data = @baseSerialize()
        data[model.serializationRoot or model.constructor.singular].attachment_ids = @newDocumentIds
        data
