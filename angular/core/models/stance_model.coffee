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
      @stanceChoice().pollOption()

    pollOptions: ->
      @recordStore.pollOptions.find(@pollOptionIds())

    stanceChoiceNames: ->
      _.pluck(@pollOptions(), 'name')

    pollOptionIds: ->
      _.pluck @stanceChoices(), 'pollOptionId'

    choose: (options) ->
      _.each @recordStore.stanceChoices.find(stanceId: @id), (stanceChoice) ->
        stanceChoice.remove()
        
      _.each options, (option) =>
        @recordStore.stanceChoices.create(pollOptionId: option.id, stanceId: @id)
      @

    # prepareForForm: ->
    #   @stanceChoicesAttributes = _.map(@pollOptionIds(), (id) -> { pollOptionId: id })
