BaseModel       = require 'shared/record_store/base_model'
AppConfig       = require 'shared/services/app_config'
HasDrafts       = require 'shared/mixins/has_drafts'
HasTranslations = require 'shared/mixins/has_translations'

module.exports = class StanceModel extends BaseModel
  @singular: 'stance'
  @plural: 'stances'
  @indices: ['pollId']
  @serializableAttributes: AppConfig.permittedParams.stance
  @draftParent: 'poll'
  @draftPayloadAttributes: ['reason']

  afterConstruction: ->
    HasDrafts.apply @
    HasTranslations.apply @

  defaultValues: ->
    reason: ''
    visitorAttributes: {}

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

  edited: ->
    @versionsCount > 1

  scoreFor: (option) ->
    choiceForOption = _.find @stanceChoices(), (choice)->
      choice.pollOptionId == option.id

    if choiceForOption then choiceForOption.score else 0
