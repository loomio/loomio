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
      @payload[model.constructor.singular] = model.serialize()[model.constructor.singular]
      @save()
