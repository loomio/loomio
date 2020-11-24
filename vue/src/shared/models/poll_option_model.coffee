import BaseModel  from  '@/shared/record_store/base_model'
import Records  from  '@/shared/services/records'
import {map} from 'lodash'


export default class PollOptionModel extends BaseModel
  @singular: 'pollOption'
  @plural: 'pollOptions'
  @indices: ['pollId']

  relationships: ->
    @belongsTo 'poll'
    @hasMany   'stanceChoices'

  stances: ->
    stanceIds = map @stanceChoices(), 'stanceId'
    Records.stances.find(id: {$in: stanceIds}, latest: true, revokedAt: null)

  beforeRemove: ->
    @stances().each (stance) -> stance.remove()
