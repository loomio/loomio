import BaseModel from '@/shared/record_store/base_model'
import AppConfig from '@/shared/services/app_config'

export default class ReactionModel extends BaseModel
  @singular: 'reaction'
  @plural: 'reactions'
  @indices: ['userId', 'reactableId']

  relationships: ->
    @belongsTo 'user'

  model: ->
    @recordStore["#{@reactableType.toLowerCase()}s"].find(@reactableId)
