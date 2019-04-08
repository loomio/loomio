import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class DraftModel extends BaseModel
  @singular: 'draft'
  @plural: 'drafts'
  @uniqueIndices: ['id']

  updateFrom: (model) ->
    payloadField = _.snakeCase(model.constructor.serializationRoot or model.constructor.singular)
    @payload[payloadField] = _.pick(model.serialize()[payloadField], model.constructor.draftPayloadAttributes)
    @remote.post("#{@draftableType.toLowerCase()}/#{@draftableId}", @serialize())
