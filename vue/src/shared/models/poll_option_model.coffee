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
    if @poll().config().poll_option_name_format == 'i18n'
      I18n.t('poll_' + @poll().pollType + '_options.' + @name)
    else
      @name