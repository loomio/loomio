import BaseModel        from '@/shared/record_store/base_model'
import AppConfig        from '@/shared/services/app_config'
import HasDrafts        from '@/shared/mixins/has_drafts'
import HasDocuments     from '@/shared/mixins/has_documents'
import HasTranslations  from '@/shared/mixins/has_translations'

export default class OutcomeModel extends BaseModel
  @singular: 'outcome'
  @plural: 'outcomes'
  @indices: ['pollId', 'authorId']
  @draftParent: 'poll'
  @draftPayloadAttributes: ['statement']

  defaultValues: ->
    statement: ''
    statementFormat: 'html'
    customFields: {}
    files: []
    imageFiles: []
    attachments: []

  afterConstruction: ->
    HasDrafts.apply @
    HasDocuments.apply @
    HasTranslations.apply @

  relationships: ->
    @belongsTo 'author', from: 'users'
    @belongsTo 'poll'

  reactions: ->
    @recordStore.reactions.find
      reactableId: @id
      reactableType: _.capitalize(@constructor.singular)

  authorName: ->
    @author().nameWithTitle(@poll()) if @author()

  group: ->
    @poll().group() if @poll()

  members: ->
    @poll().members()

  memberIds: ->
    @poll().memberIds()

  announcementSize: ->
    @poll().announcementSize @notifyAction()

  discussion: ->
    @poll().discussion()

  notifyAction: ->
    'publish'
