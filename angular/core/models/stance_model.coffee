angular.module('loomioApp').factory 'StanceModel', (DraftableModel, AppConfig, MentionLinkService) ->
  class StanceModel extends DraftableModel
    @singular: 'stance'
    @plural: 'stances'
    @indices: ['pollId', 'authorId']
    @serializableAttributes: AppConfig.permittedParams.stance
    @draftParent: 'poll'

    defaultValues: ->
      reason: ''

    relationships: ->
      @belongsTo 'poll'
      @hasMany 'stanceChoices'
      @belongsTo 'participant', from: 'users'

    stanceChoice: ->
      _.first @stanceChoices()

    pollOption: ->
      @stanceChoice().pollOption()

    pollOptions: ->
      @recordStore.pollOptions.where(id: @pollOptionIds())

    pollOptionIds: ->
      _.pluck @stanceChoices, 'pollOptionId'
