import BaseModel from '@/shared/record_store/base_model'
import i18n from '@/i18n.coffee'

export default class EventModel extends BaseModel
  @singular: 'event'
  @plural: 'events'
  @indices: ['id', 'actorId', 'discussionId', 'sequenceId', 'position', 'depth', 'parentId']

  @eventTypeMap:
    Group: 'groups'
    Discussion: 'discussions'
    Poll: 'polls'
    Outcome: 'outcomes'
    Stance: 'stances'
    Comment: 'comments'
    CommentVote: 'comments'
    Membership: 'memberships'
    MembershipRequest: 'membershipRequests'

  relationships: ->
    @belongsTo 'parent', from: 'events'
    @belongsTo 'actor', from: 'users'
    @belongsTo 'discussion'
    @hasMany  'notifications'

  defaultValues: ->
    pinned: false

  parentOrSelf: ->
    if @parentId
      @parent()
    else
      @

  isNested: -> @depth > 1
  isSurface: -> @depth == 1
  surfaceOrSelf: -> if @isNested() then @parent() else @

  children: ->
    @recordStore.events.find(parentId: @id)

  delete: ->
    @deleted = true

  actorName: ->
    if @actor()
      @actor().nameWithTitle(@discussion())
    else
      i18n.t('common.anonymous')

  actorUsername: ->
    @actor().username if @actor()

  model: ->
    @recordStore[@constructor.eventTypeMap[@eventableType]].find(@eventableId)

  isUnread: ->
    !@discussion().hasRead(@sequenceId)

  markAsRead: ->
    @discussion().markAsRead(@sequenceId) if @discussion()

  beforeRemove: ->
    _.invokeMap(@notifications(), 'remove')

  removeFromThread: =>
    @remote.patchMember(@id, 'remove_from_thread').then => @remove()

  pin: -> @remote.patchMember(@id, 'pin')
  unpin: -> @remote.patchMember(@id, 'unpin')

  isForkable: ->
    @discussion() && @discussion().isForking && @kind == 'new_comment'

  isForking: ->
    @discussion() && (@discussion().forkedEventIds.includes(@id) or @parentIsForking())

  parentIsForking: ->
    @parent() && @parent().isForking()

  toggleFromFork: ->
    if @isForking()
      @discussion().update(forkedEventIds: _.without @discussion().forkedEventIds, @id)
    else
      @discussion().update(isForking: true)
      @discussion().forkedEventIds.push @id

  next: ->
    @recordStore.events.find(parentId: @parentId, position: @position + 1)[0]

  previous: ->
    @recordStore.events.find(parentId: @parentId, position: @position - 1)[0]
