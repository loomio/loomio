import BaseModel       from '@/shared/record_store/base_model'
import AppConfig       from '@/shared/services/app_config'
import HasDrafts       from '@/shared/mixins/has_drafts'
import HasDocuments    from '@/shared/mixins/has_documents'
import HasMentions     from '@/shared/mixins/has_mentions'
import HasTranslations from '@/shared/mixins/has_translations'

export default class CommentModel extends BaseModel
  @singular: 'comment'
  @plural: 'comments'
  @indices: ['discussionId', 'authorId']
  @draftParent: 'discussion'
  @draftPayloadAttributes: ['body', 'document_ids']

  afterConstruction: ->
    HasDrafts.apply @
    HasDocuments.apply @
    HasMentions.apply @, 'body'
    HasTranslations.apply @

  defaultValues: ->
    usesMarkdown: true
    discussionId: null
    body: ''
    bodyFormat: 'html'
    mentionedUsernames: []

  relationships: ->
    @belongsTo 'author', from: 'users'
    @belongsTo 'discussion'
    @belongsTo 'parent', from: 'comments', by: 'parentId'
    @hasMany  'versions', sortBy: 'createdAt'

  createdEvent: ->
    @recordStore.events.find(kind: "new_comment", eventableId: @id)[0]

  reactions: ->
    @recordStore.reactions.find
      reactableId: @id
      reactableType: _.capitalize(@constructor.singular)

  group: ->
    @discussion().group()

  guestGroup: ->
    @discussion().guestGroup()

  memberIds: ->
    @discussion().memberIds()

  isMostRecent: ->
    _.last(@discussion().comments()) == @

  isReply: ->
    @parentId?

  hasDescription: ->
    !!@body

  parent: ->
    @recordStore.comments.find(@parentId)

  reactors: ->
    @recordStore.users.find(_.map(@reactions(), 'userId'))

  authorName: ->
    @author().nameWithTitle(@discussion()) if @author()

  authorUsername: ->
    @author().username

  authorAvatar: ->
    @author().avatarOrInitials()

  beforeDestroy: ->
    _.invokeMap @recordStore.events.find(kind: 'new_comment', eventableId: @id), 'remove'

  edited: ->
    @versionsCount > 1
