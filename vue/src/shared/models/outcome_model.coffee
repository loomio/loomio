import BaseModel        from '@/shared/record_store/base_model'
import AppConfig        from '@/shared/services/app_config'
import HasDocuments     from '@/shared/mixins/has_documents'
import HasTranslations  from '@/shared/mixins/has_translations'
import {capitalize} from 'lodash-es'

export default class OutcomeModel extends BaseModel
  @singular: 'outcome'
  @plural: 'outcomes'
  @indices: ['pollId', 'authorId']

  defaultValues: ->
    statement: ''
    statementFormat: 'html'
    customFields: {}
    files: []
    imageFiles: []
    attachments: []

  afterConstruction: ->
    HasDocuments.apply @
    HasTranslations.apply @

  relationships: ->
    @belongsTo 'author', from: 'users'
    @belongsTo 'poll'
    @belongsTo 'pollOption'

  reactions: ->
    @recordStore.reactions.find
      reactableId: @id
      reactableType: capitalize(@constructor.singular)

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
