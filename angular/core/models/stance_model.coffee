angular.module('loomioApp').factory 'StanceModel', (DraftableModel, AppConfig, MentionLinkService) ->
  class StanceModel extends DraftableModel
    @singular: 'stance'
    @plural: 'stances'
    @indices: ['pollId', 'authorId']
    @serializableAttributes: AppConfig.permittedParams.stance
    @draftParent: 'poll'
    @draftPayloadAttributes: ['reason']

    defaultValues: ->
      reason: ''
      visitorAttributes: {}

    relationships: ->
      @belongsTo 'poll'
      @hasMany 'stanceChoices'

    participant: ->
      @recordStore.users.find(@userId) or @recordStore.visitors.find(@visitorId)

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

      _.each _.flatten([optionIds]), (optionId) =>
        @recordStore.stanceChoices.create(pollOptionId: parseInt(optionId), stanceId: @id)
      @

    votedFor: (option) ->
      _.contains _.pluck(@pollOptions(), 'id'), option.id
