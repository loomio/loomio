import BaseModel        from '@/shared/record_store/base_model'
import AppConfig        from '@/shared/services/app_config'
import Session          from '@/shared/services/session'
import RangeSet         from '@/shared/services/range_set'
import HasDocuments     from '@/shared/mixins/has_documents'
import HasTranslations  from '@/shared/mixins/has_translations'
import { isEqual, isAfter } from 'date-fns'

export default class DiscussionModel extends BaseModel
  @singular: 'discussion'
  @plural: 'discussions'
  @uniqueIndices: ['id', 'key']
  @indices: ['groupId', 'authorId']
  @draftParent: 'group'
  @draftPayloadAttributes: ['title', 'description']

  afterConstruction: ->
    @private = @privateDefaultValue() if @isNew()
    HasDocuments.apply @, showTitle: true
    HasTranslations.apply @

  defaultValues: ->
    private: null
    usesMarkdown: true
    lastItemAt: null
    title: ''
    description: ''
    descriptionFormat: 'html'
    forkedEventIds: []
    ranges: []
    readRanges: []
    isForking: false
    newestFirst: false
    files: []
    imageFiles: []
    attachments: []

  audienceValues: ->
    name: @group().name

  privateDefaultValue: =>
    if @group()
      switch @group().discussionPrivacyOptions
        when 'private_only' then true
        when 'public_or_private' then true
        when 'public_only' then false
    else
      null

  relationships: ->
    @hasMany 'comments', sortBy: 'createdAt'
    @hasMany 'events', sortBy: 'sequenceId'
    @hasMany 'polls', sortBy: 'createdAt', sortDesc: true
    @hasMany 'versions', sortBy: 'createdAt'
    @belongsTo 'group'
    @belongsTo 'author', from: 'users'
    # @belongsTo 'createdEvent', from: 'events'
    # @belongsTo 'forkedEvent', from: 'events'

  discussion: -> @

  members: ->
    # pull out the discussion_readers user_ids
    @recordStore.users.find(@group().memberIds())

  membersInclude: (user) ->
    (@inviterId && !@revokedAt && Session.user() == user) or
    @group().membersInclude(user)

  adminsInclude: (user) ->
    @author() == user or
    (@inviterId && @admin && !@revokedAt && Session.user() == user) or
    @group().adminsInclude(user)

  createdEvent: ->
    res = @recordStore.events.find(kind: 'new_discussion', eventableId: @id)
    res[0] unless _.isEmpty(res)

  forkedEvent: ->
    res = @recordStore.events.find(kind: 'discussion_forked', eventableId: @id)
    res[0] unless _.isEmpty(res)

  reactions: ->
    @recordStore.reactions.find(reactableId: @id, reactableType: "Discussion")

  translationOptions: ->
    title: @title
    groupName: @groupName()

  authorName: ->
    @author().nameWithTitle(@)

  groupName: ->
    @group().name if @group()

  activePolls: ->
    _.filter @polls(), (poll) ->
      poll.isActive()

  hasActivePoll: ->
    _.some @activePolls()

  hasDecision: ->
    @hasActivePoll()

  closedPolls: ->
    _.filter @polls(), (poll) ->
      !poll.isActive()

  activePoll: ->
    _.head @activePolls()

  isUnread: ->
    !@isDismissed() and
    @discussionReaderId? and (!@lastReadAt? or @unreadItemsCount() > 0)

  isDismissed: ->
    @discussionReaderId? and @dismissedAt? and
    (isEqual(@dismissedAt, @lastActivityAt) or isAfter(@dismissedAt, @lastActivityAt))

  hasUnreadActivity: ->
    @isUnread() && @unreadItemsCount() > 0

  hasDescription: ->
    !!@description

  requireReloadFor: (event) ->
    return false if !event or event.discussionId != @id or event.sequenceId
    _.find @events(), (e) -> e.kind == 'new_comment' and e.eventable.id == event.eventable.id

  minLoadedSequenceId: ->
    item = _.min @events(), (event) -> event.sequenceId or Number.MAX_VALUE
    item.sequenceId

  maxLoadedSequenceId: ->
    item = _.max @events(), (event) -> event.sequenceId or 0
    item.sequenceId

  allEventsLoaded: ->
    @recordStore.events.find(discussionId: @id).length == @itemsCount

  membership: ->
    @recordStore.memberships.find(userId: AppConfig.currentUserId, groupId: @groupId)[0]

  membershipVolume: ->
    @membership().volume if @membership()

  volume: ->
    @discussionReaderVolume or @membershipVolume()

  saveVolume: (volume, applyToAll = false) =>
    @processing = true
    if applyToAll
      @membership().saveVolume(volume).finally => @processing = false
    else
      @discussionReaderVolume = volume if volume?
      @remote.patchMember(@keyOrId(), 'set_volume', { volume: @discussionReaderVolume }).finally =>
        @processing = false

  isMuted: ->
    @volume() == 'mute'

  markAsSeen: ->
    return unless @discussionReaderId and !@lastReadAt
    @remote.patchMember @keyOrId(), 'mark_as_seen'
    @update(lastReadAt: new Date)

  markAsRead: (id) ->
    return if !@discussionReaderId or @hasRead(id)
    @readRanges.push([id,id])
    @readRanges = RangeSet.reduce(@readRanges)
    @updateReadRanges()

  update: (attributes) ->
    if _.isArray(@readRanges) && _.isArray(attributes.readRanges) && !_.isEqual(attributes.readRanges, @readRanges)
      attributes.readRanges = RangeSet.reduce(@readRanges.concat(attributes.readRanges))
    @baseUpdate(attributes)
    @readRanges = RangeSet.intersectRanges(@readRanges, @ranges)

  updateReadRanges: _.throttle ->
    @remote.patchMember @keyOrId(), 'mark_as_read', ranges: RangeSet.serialize(@readRanges)
  , 2000

  hasRead: (id) ->
    RangeSet.includesValue(@readRanges, id)

  unreadItemsCount: ->
    @itemsCount - @readItemsCount()

  readItemsCount: ->
    RangeSet.length(@readRanges)

  firstSequenceId: ->
    (_.head(@ranges) || [])[0]

  lastSequenceId: ->
    (_.last(@ranges) || [])[1]

  lastReadSequenceId: ->
    (_.last(@readRanges) || [])[1]

  firstUnreadSequenceId: ->
    RangeSet.firstMissing(@ranges, @readRanges)

  dismiss: ->
    @update(dismissedAt: new Date)
    @processing = true
    @remote.patchMember(@keyOrId(), 'dismiss').finally => @processing = false

  recall: ->
    @update(dismissedAt: null)
    @processing = true
    @remote.patchMember(@keyOrId(), 'recall').finally => @processing = false

  move: =>
    @processing = true
    @remote.patchMember(@keyOrId(), 'move', { group_id: @groupId }).finally => @processing = false

  savePin: =>
    @processing = true
    @remote.patchMember(@keyOrId(), 'pin').finally => @processing = false

  close: =>
    @processing = true
    @remote.patchMember(@keyOrId(), 'close').finally => @processing = false

  reopen: =>
    @processing = true
    @remote.patchMember(@keyOrId(), 'reopen').finally => @processing = false

  fork: =>
    @processing = true
    @remote.post('fork', @serialize()).finally => @processing = false

  moveComments: =>
    @processing = true
    @remote.patchMember(@keyOrId(), 'move_comments', { forked_event_ids: @forkedEventIds }).finally => @processing = false

  # isForking: ->
  #   @forkedEventIds.length > 0

  forkedEvents: ->
    _.sortBy(@recordStore.events.find(@forkedEventIds), 'sequenceId')

  forkTarget: ->
    @forkedEvents()[0].model() if _.some @forkedEvents()
