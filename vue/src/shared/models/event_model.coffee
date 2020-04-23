import BaseModel from '@/shared/record_store/base_model'
import i18n from '@/i18n.coffee'
import {invokeMap, without} from 'lodash-es'

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
    invokeMap(@notifications(), 'remove')

  removeFromThread: =>
    @remote.patchMember(@id, 'remove_from_thread').then => @remove()

  pin: (title) ->
    @remote.patchMember(@id, 'pin', {pinned_title: title})

  suggestedTitle: ->
    model = @model()
    return '' unless model

    if model.title
      model.title.replace(///<[^>]*>?///gm, '')
    else
      parser = new DOMParser()
      doc = parser.parseFromString(model.statement || model.body, 'text/html')
      if el = doc.querySelector('h1,h2,h3')
        el.textContent
      else
        ''

  unpin: -> @remote.patchMember(@id, 'unpin')

  isForkable: ->
    @discussion() && @discussion().isForking

  isForking: ->
    @discussion() && (@discussion().forkedEventIds.includes(@id) or @parentIsForking())

  parentIsForking: ->
    @parent() && @parent().isForking()

  forkingDisabled: ->
    @parentIsForking() || (@parent() && @parent().kind == 'poll_created')

  toggleFromFork: ->
    if @isForking()
      @discussion().update(forkedEventIds: without @discussion().forkedEventIds, @id)
    else
      @discussion().update(isForking: true)
      @discussion().forkedEventIds.push @id

  next: ->
    @recordStore.events.find(parentId: @parentId, position: @position + 1)[0]

  previous: ->
    @recordStore.events.find(parentId: @parentId, position: @position - 1)[0]
