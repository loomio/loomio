AppConfig = require 'shared/services/app_config.coffee'

angular.module('loomioApp').factory 'DraftModel', (BaseModel) ->
  class DraftModel extends BaseModel
    @singular: 'draft'
    @plural: 'drafts'
    @uniqueIndices: ['id']
    @serializableAttributes: AppConfig.permittedParams.draft

    updateFrom: (model) ->
      payloadField = _.snakeCase(model.constructor.serializationRoot or model.constructor.singular)
      @payload[payloadField] = _.pick(model.serialize()[payloadField], model.constructor.draftPayloadAttributes)
      @remote.post("#{@draftableType.toLowerCase()}/#{@draftableId}", @serialize())
