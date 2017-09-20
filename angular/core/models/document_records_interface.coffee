angular.module('loomioApp').factory 'DocumentRecordsInterface', (BaseRecordsInterface, DocumentModel) ->
  class DocumentRecordsInterface extends BaseRecordsInterface
    model: DocumentModel
