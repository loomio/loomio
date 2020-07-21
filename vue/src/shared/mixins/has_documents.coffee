import {capitalize, uniq, union, filter, map, includes } from 'lodash-es'

export default new class HasDocuments
  apply: (model, opts = {}) ->
    model.newDocumentIds     = model.newDocumentIds or []
    model.removedDocumentIds = model.removedDocumentIds or []

    model.documents = ->
      model.recordStore.documents.find
        modelId: model.id
        modelType: capitalize(model.constructor.singular)

    model.newDocuments = ->
      model.recordStore.documents.find(model.newDocumentIds)

    model.newAndPersistedDocuments = ->
      uniq filter union(model.documents(), model.newDocuments()), (doc) ->
        !includes model.removedDocumentIds, doc.id

    model.hasDocuments = ->
      model.newAndPersistedDocuments().length > 0

    model.serialize = ->
      data = @baseSerialize()
      root = model.constructor.serializationRoot or model.constructor.singular
      data[root].document_ids = map model.newAndPersistedDocuments(), 'id'
      data

    model.showDocumentTitle = opts.showTitle
    model.documentsApplied = true
