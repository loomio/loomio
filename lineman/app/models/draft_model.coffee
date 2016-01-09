angular.module('loomioApp').factory 'DraftModel', (BaseModel, AppConfig) ->
  class DraftModel extends BaseModel
    @singular: 'draft'
    @plural: 'drafts'
    @uniqueIndices: ['id']
    @serializableAttributes: AppConfig.permittedParams.draft

    afterConstruction: ->
      draftPath = => "#{@remote.apiPrefix}/#{@constructor.plural}/#{@draftableType.toLowerCase()}/#{@draftableId}"
      @remote.collectionPath = @remote.memberPath = draftPath

    updateFrom: (model) ->
      payloadField = model.constructor.serializationRoot or model.constructor.singular
      @payload[payloadField] = model.serialize()[payloadField]
      @save()
