angular.module('loomioApp').factory 'OutcomeModel', (DraftableModel, AppConfig, MentionLinkService) ->
  class OutcomeModel extends DraftableModel
    @singular: 'outcome'
    @plural: 'outcomes'
    @indices: ['pollId', 'authorId']
    @serializableAttributes: AppConfig.permittedParams.outcome
    @draftParent: 'poll'
    @draftPayloadAttributes: ['statement']

    defaultValues: ->
      statement: ''
      newAttachmentIds: []
      customFields: {}

    afterConstruction: ->
      @newAttachmentIds = _.clone(@attachmentIds) or []

    serialize: ->
      data = @baseSerialize()
      data.outcome.attachment_ids = @newAttachmentIds
      data

    newAttachments: ->
      @recordStore.attachments.find(@newAttachmentIds)

    attachments: ->
      @recordStore.attachments.find(attachableId: @id, attachableType: 'Outcome')

    hasAttachments: ->
      _.some @attachments()

    relationships: ->
      @belongsTo 'author', from: 'users'
      @belongsTo 'poll'

    group: ->
      @poll().group() if @poll()

    announcementSize: ->
      @poll().announcementSize @notifyAction()

    notifyAction: ->
      'publish'
