import BaseModel        from '@/shared/record_store/base_model'
import AppConfig        from '@/shared/services/app_config'
import HasDocuments     from '@/shared/mixins/has_documents'
import HasTranslations  from '@/shared/mixins/has_translations'
import NullGroupModel   from '@/shared/models/null_group_model'
import {capitalize} from 'lodash'

export default class OutcomeModel extends BaseModel
  @singular: 'outcome'
  @plural: 'outcomes'
  @indices: ['pollId', 'authorId']

  defaultValues: ->
    statement: '<p></p>'
    statementFormat: 'html'
    customFields: {}
    calendarInvite: false
    includeActor: false
    files: []
    imageFiles: []
    attachments: []
    recipientUserIds: []
    recipientEmails: []
    recipientAudience: null
    groupId: null
    reviewOn: null

  afterConstruction: ->
    HasDocuments.apply @
    HasTranslations.apply @

  relationships: ->
    @belongsTo 'author', from: 'users'
    @belongsTo 'poll'
    @belongsTo 'group'
    @belongsTo 'pollOption'

  reactions: ->
    @recordStore.reactions.find
      reactableId: @id
      reactableType: capitalize(@constructor.singular)

  authorName: ->
    @author().nameWithTitle(@poll().group())

  members: ->
    @poll().members()

  membersInclude: (user) ->
    @poll().membersInclude(user)

  adminsInclude: (user) ->
    @poll().adminsInclude(user)

  memberIds: ->
    @poll().memberIds()

  announcementSize: ->
    @poll().announcementSize @notifyAction()

  discussion: ->
    @poll().discussion()

  notifyAction: ->
    'publish'

  bestNamedId: ->
    ((@id && @) || (@pollId && @poll()) || (@groupId && @group()) || {namedId: ->}).namedId()
