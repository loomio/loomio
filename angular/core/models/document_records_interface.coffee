angular.module('loomioApp').factory 'DocumentRecordsInterface', (BaseRecordsInterface, DocumentModel) ->
  class DocumentRecordsInterface extends BaseRecordsInterface
    model: DocumentModel

    fetchByModel: (model) ->
      @fetch
        params:
          "#{model.constructor.singular}_id": model.id

    fetchByGroup: (group, query, options) ->
      options.q = query
      options.group_key = group.key
      @fetch
        path: 'for_group'
        params: options

    buildFromModel: (model) ->
      @build
        modelId:   model.id
        modelType: _.capitalize model.constructor.singular

    upload: (file, progress) ->
      @remote.upload '', file,
        data:
          'document[filename]': file.name.replace(/[^a-z0-9_\-\.]/gi, '_')
        fileFormDataName: 'document[file]'
      , progress
