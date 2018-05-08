BaseModel        = require 'shared/record_store/base_model'
AppConfig        = require 'shared/services/app_config'
HasDrafts        = require 'shared/mixins/has_drafts'
HasDocuments     = require 'shared/mixins/has_documents'
HasTranslations  = require 'shared/mixins/has_translations'

module.exports = class OutcomeModel extends BaseModel
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
    HasTranslations.apply @

  relationships: ->
    @belongsTo 'author', from: 'users'
    @belongsTo 'poll'

  group: ->
    @poll().group() if @poll()

  announcementSize: ->
    @poll().announcementSize @notifyAction()

  discussion: ->
    @poll().discussion()

  notifyAction: ->
    'publish'
