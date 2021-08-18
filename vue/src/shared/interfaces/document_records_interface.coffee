import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import DocumentModel        from '@/shared/models/document_model'
import {flatten, capitalize, includes} from 'lodash'

export default class DocumentRecordsInterface extends BaseRecordsInterface
  model: DocumentModel

  fetchByModel: (model) ->
    @fetch
      params:
        "#{model.constructor.singular}_id": model.id

  fetchByDiscussion: (discussion) ->
    @fetch
      path: 'for_discussion'
      params:
        discussion_key: discussion.key
