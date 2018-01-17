angular.module('loomioApp').factory 'OutcomeModel', (BaseModel, HasDrafts, HasDocuments, AppConfig, MentionLinkService) ->
  class OutcomeModel extends BaseModel
    @singular: 'outcome'
    @plural: 'outcomes'
    @indices: ['pollId', 'authorId']
    @serializableAttributes: AppConfig.permittedParams.outcome
    @draftParent: 'poll'
    @draftPayloadAttributes: ['statement']

    defaultValues: ->
      statement: ''
      customFields: {}

    afterConstruction: ->
      HasDrafts.apply @
      HasDocuments.apply @

    relationships: ->
      @belongsTo 'author', from: 'users'
      @belongsTo 'poll'

    group: ->
      @poll().group() if @poll()

    announcementSize: ->
      @poll().announcementSize @notifyAction()

    notifyAction: ->
      'publish'
