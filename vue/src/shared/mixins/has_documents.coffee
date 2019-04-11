export default new class HasDocuments
  apply: (model, opts = {}) ->
    model.newDocumentIds     = model.newDocumentIds or []
    model.removedDocumentIds = model.removedDocumentIds or []

    model.documents = ->
      model.recordStore.documents.find
        modelId: model.id
        modelType: _.capitalize(model.constructor.singular)

    model.newDocuments = ->
      model.recordStore.documents.find(model.newDocumentIds)

    model.newAndPersistedDocuments = ->
      _.uniq _.filter _.union(model.documents(), model.newDocuments()), (doc) ->
        !_.includes model.removedDocumentIds, doc.id

    model.hasDocuments = ->
      model.newAndPersistedDocuments().length > 0

    model.serialize = ->
      data = @baseSerialize()
      root = model.constructor.serializationRoot or model.constructor.singular
      data[root].document_ids = _.map model.newAndPersistedDocuments(), 'id'
      data

    model.showDocumentTitle = opts.showTitle
    model.documentsApplied = true
