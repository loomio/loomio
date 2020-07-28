import BaseModel  from  '@/shared/record_store/base_model'
import Records  from  '@/shared/services/records'
import {map} from 'lodash-es'

export default class PollOptionModel extends BaseModel
  @singular: 'pollOption'
  @plural: 'pollOptions'
  @indices: ['pollId']

  relationships: ->
    @belongsTo 'poll'
    @hasMany   'stanceChoices'

  stances: ->
    stanceIds = map @stanceChoices(), 'stanceId'
    Records.stances.find(latest: true, id: {$in: stanceIds})

  beforeRemove: ->
    @stances().each (stance) -> stance.remove()
