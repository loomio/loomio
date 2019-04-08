BaseModel = require '@/shared/record_store/base_model'
AppConfig = require '@/shared/services/app_config'

export default class StanceChoiceModel extends BaseModel
  @singular: 'stanceChoice'
  @plural: 'stanceChoices'
  @indices: ['pollOptionId', 'stanceId']

  defaultValues: ->
    score: 1

  relationships: ->
    @belongsTo 'pollOption'
    @belongsTo 'stance'

  poll: ->
    @stance().poll() if @stance()
