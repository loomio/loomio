import BaseModel  from  '@/shared/record_store/base_model'
import {chain, each} from 'lodash'

export default class PollOptionModel extends BaseModel
  @singular: 'pollOption'
  @plural: 'pollOptions'
  @indices: ['pollId']

  relationships: ->
    @belongsTo 'poll'
    @hasMany   'stanceChoices'

  stances: ->
    chain(@stanceChoices()).
    map((stanceChoice) -> stanceChoice.stance()).
    filter((stance) -> stance.latest).
    compact().value()

  beforeRemove: ->
    each @stances(), (stance) -> stance.remove()
