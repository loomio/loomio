angular.module('loomioApp').factory 'StanceModel', (DraftableModel, AppConfig, MentionLinkService) ->
  class StanceModel extends DraftableModel
    @singular: 'stance'
    @plural: 'stances'
    @indices: ['pollId', 'authorId']
    @serializableAttributes: AppConfig.permittedParams.stance
    @draftParent: 'poll'

    defaultValues: ->
      reason: ''
      stanceChoicesAttributes: []

    relationships: ->
      @belongsTo 'poll'
      @hasMany 'stanceChoices'
      @belongsTo 'participant', from: 'users'

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

    # prepareForForm: ->
    #   @stanceChoicesAttributes = _.map(@pollOptionIds(), (id) -> { pollOptionId: id })
