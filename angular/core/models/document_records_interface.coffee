angular.module('loomioApp').factory 'DocumentRecordsInterface', (BaseRecordsInterface, DocumentModel) ->
  class DocumentRecordsInterface extends BaseRecordsInterface
    model: DocumentModel

    fetchByModel: (model) ->
      @fetch
        params:
          "#{model.constructor.singular}_id": model.id
