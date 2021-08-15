import BaseModel       from '@/shared/record_store/base_model'
import AppConfig       from '@/shared/services/app_config'
import HasTranslations from '@/shared/mixins/has_translations'
import AnonymousUserModel   from '@/shared/models/anonymous_user_model'
import i18n from '@/i18n.coffee'
import { sumBy, map, head, each, compact, flatten, includes, find, sortBy, parseInt } from 'lodash'

stancesBecameUpdatable = new Date("2020-08-11")

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
    linkPreviews: []
    revokedAt: null
    participantId: null
    pollId: null
    optionScores: {}

  relationships: ->
    @belongsTo 'poll'
    @belongsTo 'participant', from: 'users'

  edited: ->
    if @createdAt > stancesBecameUpdatable
      @versionsCount > 2
    else
      @versionsCount > 1

  participantName: ->
    if @participant()
      @participant().nameWithTitle(@poll().group())
    else
      i18n.t('common.anonymous')

  reactions: ->
    @recordStore.reactions.find(reactableId: @id, reactableType: "Stance")

  singleChoice: -> @poll().singleChoice()

  participantIds: ->
    @poll().participantIds()

  memberIds: ->
    @poll().memberIds()

  group: ->
    @poll().group()

  isBlank: ->
    @reason == '' or @reason == null or @reason == '<p></p>'

  author: ->
    @participant()

  reasonTooLong: ->
    !@poll().allowLongReason && @reason.length > 500
    
  stanceChoice: ->
    head @sortedChoices()

  pollOption: ->
    @recordStore.pollOptions.find(@pollOptionId()) if @pollOptionId()

  pollOptionId: ->
    @pollOptionIds()[0]

  pollOptionIds: ->
    map Object.keys(@optionScores), parseInt

  pollOptions: ->
    @recordStore.pollOptions.find(@pollOptionIds())

  choose: (optionIds) ->
    @optionScores = {}
    compact(flatten([optionIds])).forEach (id) ->
      @optionScores[id] = 1
    @

  sortedChoices: ->
    optionsById = {}
    @pollOptions().forEach (o) -> optionsById[o.id] = o
    poll = @poll()

    choices = map @optionScores, (score, pollOptionId) =>
      {
        score: score,
        rank: (poll.pollType == 'ranked_choice') && (poll.customFields.minimum_stance_choices - score + 1),
        show: (score > 0) || poll.pollType == "score",
        pollOption: optionsById[pollOptionId]
      }

    if poll.pollType == 'meeting'
      sortBy choices, (c) -> c.pollOption.priority
    else
      sortBy choices, '-score'

  votedFor: (option) ->
    includes map(@pollOptions(), 'id'), option.id

  scoreFor: (option) ->
    @optionScores[option.id] || 0

  totalScore: ->
    sumBy(@sortedChoices(), 'score')
