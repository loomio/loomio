import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import DocumentModel        from '@/shared/models/document_model'
import {flatten, capitalize, includes} from 'lodash'

export default class DocumentRecordsInterface extends BaseRecordsInterface
  model: DocumentModel

  newAndPersistedDocumentsFor: (model) ->
    @view "newAndPersistedDocumentsFor(#{model.constructor.singular}, #{model.id})", (v) ->
      v.applyFind(modelId: $in: flatten([model.id, model.newDocumentIds]) )
      v.applyFind(modelType: capitalize(model.constructor.singular))
      v.applyWhere((doc) -> !includes model.removedDocumentIds, doc.id)
      v.applySimpleSort('createdAt', true)

  fetchByModel: (model) ->
    @fetch
      params:
        "#{model.constructor.singular}_id": model.id

  fetchByGroup: (group, query, options = {}) ->
    options.q = query if query?
    options.group_key = group.key
    @fetch
      path: 'for_group'
      params: options

  fetchByDiscussion: (discussion) ->
    @fetch
      path: 'for_discussion'
      params:
        discussion_key: discussion.key

  buildFromModel: (model) ->
    @build
      modelId:   model.id
      modelType: _.capitalize model.constructor.singular

  upload: (file, progress) =>
    @remote.upload '', file,
      fileField:     'document[file]'
      filenameField: 'document[title]'
    , progress

  abort: ->
    @remote.abort()
