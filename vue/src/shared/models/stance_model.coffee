import BaseModel       from '@/shared/record_store/base_model'
import AppConfig       from '@/shared/services/app_config'
import HasTranslations from '@/shared/mixins/has_translations'
import { sumBy, map, head, each, compact, flatten, includes, find } from 'lodash'

export default class StanceModel extends BaseModel
  @singular: 'stance'
  @plural: 'stances'
  @indices: ['pollId']
  @draftParent: 'poll'
  @draftPayloadAttributes: ['reason']

  afterConstruction: ->
    HasTranslations.apply @

  defaultValues: ->
    reason: ''
    reasonFormat: 'html'
    visitorAttributes: {}
    files: []
    imageFiles: []
    attachments: []

  relationships: ->
    @belongsTo 'poll'
    @hasMany 'stanceChoices'
    @belongsTo 'participant', from: 'users'

  reactions: ->
    @recordStore.reactions.find(reactableId: @id, reactableType: "Stance")

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
