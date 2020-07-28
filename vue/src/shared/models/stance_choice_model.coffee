import BaseModel from '@/shared/record_store/base_model'

export default class StanceChoiceModel extends BaseModel
  @singular: 'stanceChoice'
  @plural: 'stanceChoices'
  @indices: ['pollOptionId', 'stanceId']

  defaultValues: ->
    score: 1

  relationships: ->
    @belongsTo 'pollOption'
    @belongsTo 'stance'

  poll: -> @stance().poll()

  show: ->
    (@score > 0) or @poll().pollType == "score"
