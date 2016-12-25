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
      @belongsTo 'pollOption'

    cookedStatement: ->
      MentionLinkService.cook(@mentionedUsernames, @statement)
