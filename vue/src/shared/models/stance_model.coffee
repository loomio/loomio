import BaseModel       from '@/shared/record_store/base_model'
import AppConfig       from '@/shared/services/app_config'
import HasDrafts       from '@/shared/mixins/has_drafts'
import HasTranslations from '@/shared/mixins/has_translations'

export default class StanceModel extends BaseModel
  @singular: 'stance'
  @plural: 'stances'
  @indices: ['pollId']
  @draftParent: 'poll'
  @draftPayloadAttributes: ['reason']

  afterConstruction: ->
    HasDrafts.apply @
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
    _.head @stanceChoices()

  pollOption: ->
    @stanceChoice().pollOption() if @stanceChoice()

  pollOptionId: ->
    (@pollOption() or {}).id

  pollOptions: ->
    @recordStore.pollOptions.find(@pollOptionIds())

  stanceChoiceNames: ->
    _.map(@pollOptions(), 'name')

  pollOptionIds: ->
    _.map @stanceChoices(), 'pollOptionId'

  choose: (optionIds) ->
    _.each @recordStore.stanceChoices.find(stanceId: @id), (stanceChoice) ->
      stanceChoice.remove()

    _.each _.compact(_.flatten([optionIds])), (optionId) =>
      @recordStore.stanceChoices.create(pollOptionId: parseInt(optionId), stanceId: @id)
    @

  votedFor: (option) ->
    _.includes _.map(@pollOptions(), 'id'), option.id

  scoreFor: (option) ->
    choiceForOption = _.find @stanceChoices(), (choice)->
      choice.pollOptionId == option.id

    if choiceForOption then choiceForOption.score else 0
