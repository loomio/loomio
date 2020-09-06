import BaseModel       from '@/shared/record_store/base_model'
import AppConfig       from '@/shared/services/app_config'
import HasTranslations from '@/shared/mixins/has_translations'
import i18n from '@/i18n.coffee'
import { sumBy, map, head, each, compact, flatten, includes, find, orderBy } from 'lodash'

export default class StanceModel extends BaseModel
  @singular: 'stance'
  @plural: 'stances'
  @indices: ['pollId', 'latest']

  afterConstruction: ->
    HasTranslations.apply @

  defaultValues: ->
    reason: ''
    reasonFormat: 'html'
    files: []
    imageFiles: []
    attachments: []

  relationships: ->
    @belongsTo 'poll'
    @hasMany 'stanceChoices'
    @belongsTo 'participant', from: 'users'

  participantName: ->
    if @participant()
      @participant().nameWithTitle(@poll().group())
    else
      i18n.t('common.anonymous')

  reactions: ->
    @recordStore.reactions.find(reactableId: @id, reactableType: "Stance")

  singleChoice: -> @poll().singleChoice()

  memberIds: ->
    @poll().memberIds()

  group: ->
    @poll().group()

  author: ->
    @participant()

  stanceChoice: ->
    head @stanceChoices()

  pollOption: ->
    @stanceChoice().pollOption() if @stanceChoice()

  pollOptionId: ->
    (@pollOption() or {}).id

  pollOptions: ->
    @recordStore.pollOptions.find(@pollOptionIds())

  orderedStanceChoices: ->
    order = if @poll().pollType == 'ranked_choice'
      'asc'
    else
      'desc'
    compact orderBy @stanceChoices(), 'rankOrScore', order

  stanceChoiceNames: ->
    map(@pollOptions(), 'name')

  pollOptionIds: ->
    map @stanceChoices(), 'pollOptionId'

  choose: (optionIds) ->
    each @recordStore.stanceChoices.find(stanceId: @id), (stanceChoice) ->
      stanceChoice.remove()

    each compact(flatten([optionIds])), (optionId) =>
      @recordStore.stanceChoices.create(pollOptionId: parseInt(optionId), stanceId: @id)
    @

  votedFor: (option) ->
    includes map(@pollOptions(), 'id'), option.id

  scoreFor: (option) ->
    choiceForOption = find @stanceChoices(), (choice)->
      choice.pollOptionId == option.id

    if choiceForOption then choiceForOption.score else 0

  totalScore: ->
    sumBy(@stanceChoices(), 'score')
