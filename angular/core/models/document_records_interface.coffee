angular.module('loomioApp').factory 'DocumentRecordsInterface', (BaseRecordsInterface, DocumentModel) ->
  class DocumentRecordsInterface extends BaseRecordsInterface
    model: DocumentModel

    fetchByModel: (model) ->
      @fetch
        params:
          "#{model.constructor.singular}_id": model.id

    fetchByGroup: (group, query) ->
      @fetch
        path: 'for_group'
        params:
          group_key: group.key
          q:         query

    buildFromModel: (model) ->
      @build
        modelId:   model.id
        modelType: _.capitalize model.constructor.singular
