angular.module('loomioApp').factory 'DraftModel', (BaseModel, AppConfig) ->
  class DraftModel extends BaseModel
    @singular: 'draft'
    @plural: 'drafts'
    @uniqueIndices: ['id']
    @serializableAttributes: AppConfig.permittedParams.draft

    updateFrom: (model) ->
      payloadField = _.snakeCase(model.constructor.serializationRoot or model.constructor.singular)
      @payload[payloadField] = model.serialize()[payloadField]
      @remote.post("#{@draftableType.toLowerCase()}/#{@draftableId}", @serialize())
