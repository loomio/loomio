import BaseModel  from  '@/shared/record_store/base_model'
import Records  from  '@/shared/services/records'
import {map, parseInt, slice, max} from 'lodash'
import I18n from '@/i18n'

export default class PollOptionModel extends BaseModel
  @singular: 'pollOption'
  @plural: 'pollOptions'
  @indices: ['pollId']
  @uniqueIndices: ['id']

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

  # averageScore: ->
  #   voterIds = @voterIds()
  #   return 0 unless voterIds.length
  #   Math.round( (@totalScore / voterIds.length) * 10 + Number.EPSILON ) / 10

  # voterIds: ->
  #   # this is a hack, we both know this
  #   # some polls 0 is a vote, others it is not
  #   if @poll().pollType == 'meeting'
  #     Object.entries(@voterScores).map((e) -> parseInt(e[0]))
  #   else
  #     Object.entries(@voterScores).filter((e) -> e[1] > 0).map((e) -> parseInt(e[0]))

  # voters: (limit = 1000) ->
  #   @recordStore.users.find(slice(@voterIds(), 0, limit))

  # scorePercent: ->
  #   parseInt(parseFloat(@totalScore) / parseFloat(@poll().totalScore) * 100) || 0

  # rawScorePercent: ->
  #   parseFloat(@totalScore) / parseFloat(@poll().totalScore) * 100

  # barChartPct: ->
  #   parseInt((100 * parseFloat(@totalScore) / max(@poll().stanceCounts)))
