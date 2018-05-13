BaseModel = require 'shared/record_store/base_model'
AppConfig = require 'shared/services/app_config'

module.exports = class DraftModel extends BaseModel
  @singular: 'draft'
  @plural: 'drafts'
  @uniqueIndices: ['id']
  @serializableAttributes: AppConfig.permittedParams.draft

  updateFrom: (model) ->
    payloadField = _.snakeCase(model.constructor.serializationRoot or model.constructor.singular)
    @payload[payloadField] = _.pick(model.serialize()[payloadField], model.constructor.draftPayloadAttributes)
    @remote.post("#{@draftableType.toLowerCase()}/#{@draftableId}", @serialize())
