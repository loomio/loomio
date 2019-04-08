BaseModel = require '@/shared/record_store/base_model'
AppConfig = require '@/shared/services/app_config'

export default class ReactionModel extends BaseModel
  @singular: 'reaction'
  @plural: 'reactions'
  @indices: ['userId', 'reactableId']

  relationships: ->
    @belongsTo 'user'

  model: ->
    @recordStore["#{@reactableType.toLowerCase()}s"].find(@reactableId)
