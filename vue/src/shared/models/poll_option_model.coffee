import BaseModel  from  '@/shared/record_store/base_model'
import Records  from  '@/shared/services/records'
import {map, parseInt, slice} from 'lodash'
import I18n from '@/i18n'


export default class PollOptionModel extends BaseModel
  @singular: 'pollOption'
  @plural: 'pollOptions'
  @indices: ['pollId']

  defaultValues: ->
    voterScores: {}

  relationships: ->
    @belongsTo 'poll'

  stances: ->
    @poll().latestStances().filter((s) => s.pollOptionIds().includes(@id))

  beforeRemove: ->
    @stances().forEach (stance) -> stance.remove()

  optionName: ->
    if @poll().translateOptionName()
      I18n.t('poll_' + @poll().pollType + '_options.' + @name)
    else
      @name

  averageScore: ->
    voterIds = @voterIds()
    return 0 unless voterIds.length
    Math.round( (@totalScore / voterIds.length) * 10 + Number.EPSILON ) / 10

  voterIds: ->
    Object.entries(@voterScores).filter((e) -> e[1] > 0).map((e) -> parseInt(e[0]))

  voters: (limit = 1000) ->
    @recordStore.users.find(slice(@voterIds(), 0, limit))

  scorePercent: ->
    parseInt(parseFloat(@totalScore) / parseFloat(@poll().totalScore) * 100) || 0
    
  rawScorePercent: ->
    parseFloat(@totalScore) / parseFloat(@poll().totalScore) * 100
