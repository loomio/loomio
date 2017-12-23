BaseModel    = require 'shared/models/base_model'
AppConfig    = require 'shared/services/app_config.coffee'
HasDrafts    = require 'shared/mixins/has_drafts.coffee'
HasDocuments = require 'shared/mixins/has_documents.coffee'

angular.module('loomioApp').factory 'OutcomeModel', ->
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
