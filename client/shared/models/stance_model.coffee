BaseModel       = require 'shared/record_store/base_model.coffee'
AppConfig       = require 'shared/services/app_config.coffee'
HasDrafts       = require 'shared/mixins/has_drafts.coffee'
HasTranslations = require 'shared/mixins/has_translations.coffee'

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

  author: ->
    @participant()

  stanceChoice: ->
    _.first @stanceChoices()

  pollOption: ->
    @stanceChoice().pollOption() if @stanceChoice()

  pollOptionId: ->
    (@pollOption() or {}).id

  pollOptions: ->
    @recordStore.pollOptions.find(@pollOptionIds())

  stanceChoiceNames: ->
    _.pluck(@pollOptions(), 'name')

  pollOptionIds: ->
    _.pluck @stanceChoices(), 'pollOptionId'

  choose: (optionIds) ->
    _.each @recordStore.stanceChoices.find(stanceId: @id), (stanceChoice) ->
      stanceChoice.remove()

    _.each _.compact(_.flatten([optionIds])), (optionId) =>
      @recordStore.stanceChoices.create(pollOptionId: parseInt(optionId), stanceId: @id)
    @

  votedFor: (option) ->
    _.contains _.pluck(@pollOptions(), 'id'), option.id

  verify: () =>
    @remote.postMember(@id, 'verify').then => @unverified = false
