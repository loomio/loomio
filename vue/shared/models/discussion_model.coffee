BaseModel        = require 'shared/record_store/base_model'
AppConfig        = require 'shared/services/app_config'
RangeSet         = require 'shared/services/range_set'
HasDrafts        = require 'shared/mixins/has_drafts'
HasDocuments     = require 'shared/mixins/has_documents'
HasMentions      = require 'shared/mixins/has_mentions'
HasTranslations  = require 'shared/mixins/has_translations'
HasGuestGroup    = require 'shared/mixins/has_guest_group'

module.exports = class DiscussionModel extends BaseModel
  @singular: 'discussion'
  @plural: 'discussions'
  @uniqueIndices: ['id', 'key']
  @indices: ['groupId', 'authorId']
  @draftParent: 'group'
  @draftPayloadAttributes: ['title', 'description']
  @serializableAttributes: AppConfig.permittedParams.discussion

  afterConstruction: ->
    @private = @privateDefaultValue() if @isNew()
    HasDocuments.apply @, showTitle: true
    HasDrafts.apply @
    HasMentions.apply @, 'description'
    HasTranslations.apply @
    HasGuestGroup.apply @

  defaultValues: =>
    private: null
    usesMarkdown: true
    lastItemAt: null
    title: ''
    description: ''
    descriptionFormat: 'html'
    forkedEventIds: []

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
    @belongsTo 'createdEvent', from: 'events'
    @belongsTo 'forkedEvent', from: 'events'

  discussion: ->
    @

  reactions: ->
    @recordStore.reactions.find(reactableId: @id, reactableType: "Discussion")

  translationOptions: ->
    title:     @title
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
    @discussionReaderId? and @dismissedAt? and @dismissedAt.isSameOrAfter(@lastActivityAt)

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
    if applyToAll
      @membership().saveVolume(volume)
    else
      @discussionReaderVolume = volume if volume?
      @remote.patchMember @keyOrId(), 'set_volume', { volume: @discussionReaderVolume }

  isMuted: ->
    @volume() == 'mute'

  markAsSeen: ->
    return unless @discussionReaderId and !@lastReadAt
    @remote.patchMember @keyOrId(), 'mark_as_seen'
    @update(lastReadAt: moment())

  markAsRead: (id) ->
    return if !@discussionReaderId or @hasRead(id)
    @readRanges.push([id,id])
    @readRanges = RangeSet.reduce(@readRanges)
    @updateReadRanges()

  update: (attributes) ->
    if _.isArray(@readRanges) && _.isArray(attributes.readRanges) && !_.isEqual(attributes.readRanges, @readRanges)
      attributes.readRanges = RangeSet.reduce(@readRanges.concat(attributes.readRanges))
    @baseUpdate(attributes)

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
    @update(dismissedAt: moment())
    @remote.patchMember @keyOrId(), 'dismiss'

  recall: ->
    @update(dismissedAt: null)
    @remote.patchMember @keyOrId(), 'recall'

  move: =>
    @remote.patchMember @keyOrId(), 'move', { group_id: @groupId }

  savePin: =>
    @remote.patchMember @keyOrId(), 'pin'

  close: =>
    @remote.patchMember @keyOrId(), 'close'

  reopen: =>
    @remote.patchMember @keyOrId(), 'reopen'

  fork: =>
    @remote.post 'fork', @serialize()

  edited: ->
    @versionsCount > 1

  isForking: ->
    @forkedEventIds.length > 0

  forkedEvents: ->
    _.sortBy(@recordStore.events.find(@forkedEventIds), 'sequenceId')

  forkTarget: ->
    @forkedEvents()[0].model() if _.some @forkedEvents()
