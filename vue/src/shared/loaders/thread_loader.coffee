import Records from '@/shared/services/records'
import { some, last, cloneDeep, max, isNumber, uniq, compact, orderBy, camelCase, forEach, isObject, sortedUniq, sortBy, without, map } from 'lodash'
import Vue from 'vue'
import RangeSet         from '@/shared/services/range_set'
import EventBus         from '@/shared/services/event_bus'
import Session from '@/shared/services/session'

export default class ThreadLoader
  constructor: (discussion) ->
    @discussion = discussion
    @reset()

  reset: ->
    @collection = Vue.observable([])
    @rules = []
    @ruleStrings = []
    @fetchedRules = []
    @readRanges = cloneDeep @discussion.readRanges
    @focusAttrs = {}
    @visibleKeys = {}
    @collapsed = Vue.observable({})
    @loading = false
    @padding = 50
    @maxAutoLoadMore = 5

  firstUnreadSequenceId: ->
    (RangeSet.subtractRanges(@discussion.ranges, @readRanges)[0] || [])[0]

  setVisible: (isVisible, event) ->
    event.markAsRead() unless @visibleKeys.hasOwnProperty(event.positionKey)
    @visibleKeys[event.positionKey] = isVisible
    EventBus.$emit('visibleKeys', Object.keys(@visibleKeys).filter((key) => @visibleKeys[key]).sort())

  collapse: (event) ->
    Object.keys(@visibleKeys).forEach (key) =>
      @visibleKeys[key] = false if key.startsWith(event.positionKey)
    Vue.set(@collapsed, event.id, true)

  isUnread: (event) ->
    if event.kind == "new_discussion"
      @discussion.updatedAt > @discussion.lastReadAt
    else
      !RangeSet.includesValue(@readRanges, event.sequenceId)

  sequenceIdIsUnread: (id) ->
    if id == 0
      @discussion.updatedAt > @discussion.lastReadAt
    else
      !RangeSet.includesValue(@readRanges, id)

  expand: (event) ->
    Vue.set(@collapsed, event.id, false)

  jumpToEarliest: ->
    @addLoadOldestFirstRule()
    @fetch()

  jumpToLatest: ->
    @addLoadNewestFirstRule()
    @fetch()

  jumpToUnread: ->
    @addLoadUnreadRule()
    @fetch()

  jumpToSequenceId: (id) ->
    @addLoadSequenceIdRule(id)
    @fetch()

  loadEverything: ->
    @loading = true
    @addRuleAndFetch
      local:
        find:
          discussionId: @discussion.id
      remote:
        discussion_id: @discussion.id
        per: 1000

  autoLoadAfter: (obj) ->
    if (!@discussion.newestFirst && obj.event.depth == 1) || (obj.missingAfterCount && obj.missingAfterCount < @maxAutoLoadMore)
      # @loadAfter(obj.event, obj.missingAfterCount)
      @loadAfter(obj.event)

  loadAfter: (event) ->
    # @addLoadAfterRule(event, limit)
    @addLoadAfterRule(event)
    @fetch()

  autoLoadBefore: (obj) ->
    if (@discussion.newestFirst && obj.event.depth == 1) || (obj.missingEarlierCount && obj.missingEarlierCount < @maxAutoLoadMore)
      # @loadBefore(obj.event, obj.missingEarlierCount)
      @loadBefore(obj.event)

  loadBefore: (event) ->
    @loading = 'before'+event.id
    # @addLoadBeforeRule(event, limit)
    @addLoadBeforeRule(event)
    @fetch()

  # autoLoadChildren: (obj) ->
  #   if obj.missingChildCount && (obj.missingChildCount < @maxAutoLoadMore)
  #     @loadChildren(obj.event)
  #
  # loadChildren: (event) ->
  #   @loading = 'children'+event.id
  #   if event.kind == "new_discussion"
  #     @addRuleAndFetch
  #       name: "load discussion children"
  #       local:
  #         find:
  #           discussionId: @discussion.id
  #         simplesort: 'id'
  #         limit: @padding
  #       remote:
  #         discussion_id: @discussion.id
  #         order_by: 'position_key'
  #         per: @padding
  #   else
  #     @addLoadAfterRule(event)
  #     # @addRuleAndFetch
  #     #   name: "load children (prefix #{event.positionKey})"
  #     #   local:
  #     #     find:
  #     #       discussionId: @discussion.id
  #     #       positionKey: {'$regex': "^#{event.positionKey}"}
  #     #     simplesort: 'positionKey'
  #     #     limit: @padding
  #     #   remote:
  #     #     discussion_id: @discussion.id
  #     #     position_key_sw: event.positionKey
  #     #     depth_gt: event.depth
  #     #     order_by: 'position_key'
  #     #     per: @padding

  addLoadAfterRule: (event) ->
    @addRule
      name: "load after #{event.positionKey}"
      local:
        find:
          discussionId: @discussion.id
          positionKey:
            $jgt: event.positionKey
        simplesort: 'positionKey'
        limit: @padding
      remote:
        discussion_id: @discussion.id
        position_key_gt: event.positionKey
        order_by: 'position_key'
        per: @padding

  addLoadBeforeRule: (event) ->
    @addRule
      name: "load before #{event.positionKey}"
      local:
        find:
          discussionId: @discussion.id
          positionKey:
            $jlt: event.positionKey
        simplesort: 'positionKey'
        simplesortDesc: true
        limit: @padding
      remote:
        discussion_id: @discussion.id
        position_key_lt: event.positionKey
        order_by: 'position_key'
        order_desc: 1
        per: @padding

  addLoadCommentRule: (commentId) ->
    @addRule
      name: "comment from url"
      local:
        find:
          discussionId: @discussion.id
          commentId: {$gte: commentId}
        limit: @padding
      remote:
        order: 'sequence_id'
        discussion_id: @discussion.id
        comment_id: commentId

  addLoadPositionRule: (position) ->
    @addRule
      name: "position from url"
      local:
        find:
          discussionId: @discussion.id
          depth: 1
          position: {$gte: position}
        simplesort: 'positionKey'
        limit: @padding
      remote:
        discussion_id: @discussion.id
        from_sequence_id_of_position: position
        order: 'position_key'

  addLoadPositionKeyRule: (positionKey) ->
    @loading = positionKey
    @addRule
      name: "positionKey from url"
      local:
        find:
          discussionId: @discussion.id
          positionKey: {$jgte: positionKey}
        simplesort: 'positionKey'
        limit: parseInt(@padding/2)
      remote:
        discussion_id: @discussion.id
        position_key_gte: positionKey
        order_by: 'position_key'
        per: parseInt(@padding/2)

    @addRule
      name: "positionKey rollback"
      local:
        find:
          discussionId: @discussion.id
          positionKey: {$jlt: positionKey}
        simplesort: 'positionKey'
        simplesortDesc: true
        limit: parseInt(@padding/2)
      remote:
        discussion_id: @discussion.id
        position_key_lt: positionKey
        order_by: 'position_key'
        order_desc: 1
        per: parseInt(@padding/2)

  addLoadSequenceIdRule: (sequenceId) ->
    id = max([parseInt(sequenceId) - parseInt(@padding/2), 0])
    @loading = id
    @addRule
      name: "sequenceId from url"
      local:
        find:
          discussionId: @discussion.id
          sequenceId: {'$jgte': id}
        simplesort: 'sequenceId'
        limit: @padding
      remote:
        sequence_id_gte: id
        discussion_id: @discussion.id
        order: 'sequence_id'
        per: @padding

  addLoadNewestRule: ->
    @addRule
      local:
        find:
          discussionId: @discussion.id
        simplesort: 'sequenceId'
        simplesortDesc: true
        limit: @padding
      remote:
        discussion_id: @discussion.id
        order_by: 'sequence_id'
        order_desc: true
        per: @padding

  addContextRule: ->
    @addRule
      name: 'context'
      local:
        find:
          id: @discussion.createdEvent().id

  addLoadOldestRule: ->
    @addRule
      name: 'oldest'
      local:
        find:
          discussionId: @discussion.id
        simplesort: 'sequenceId'
        limit: @padding
      remote:
        discussion_id: @discussion.id
        order_by: 'sequence_id'
        per: @padding

  addLoadUnreadRule: ->
    if @discussion.updatedAt > @discussion.lastReadAt
      @addRule
        name: "context updated"
        local:
          find:
            id: @discussion.createdEvent().id

    id = max([@firstUnreadSequenceId() - parseInt(@padding/2), @discussion.firstSequenceId()])
    @addRule
      name: {path: "strand_nav.new_to_you"}
      local:
        find:
          discussionId: @discussion.id
          sequenceId: {$jgte: id}
        limit: @padding
        order: 'sequenceId'
      remote:
        discussion_id: @discussion.id
        sequence_id_gte: id
        order_by: "sequence_id"
        per: @padding

  addRule: (rule) ->
    ruleString = JSON.stringify(rule)

    if !@ruleStrings.includes(ruleString)
      @rules.push(rule)
      @ruleStrings.push(ruleString)
      # if @rules.length > 5
      #   @rules.shift()
      #   @ruleStrings.shift()
      true
    else
      false

  addRuleAndFetch: (rule) ->
    @fetch() if @addRule(rule)

  fetch:  ->
    newRules = []
    promises = @rules.filter((rule) -> rule.remote)
                     .filter((rule) => !@fetchedRules.includes(JSON.stringify(rule.remote)))
                     .map (rule) =>
      newRules.push(JSON.stringify(rule.remote))
      params = Object.assign {}, rule.remote, {exclude_types: 'group discussion'}
      Records.events.fetch(params: params)

    Promise.all(promises).finally =>
      @fetchedRules = uniq @fetchedRules.concat(newRules)
      @loading = false

  updateCollection: ->
    @records = []
    @rules.forEach (rule) =>
      chain = Records.events.collection.chain()
      chain.find(rule.local.find)

      if rule.local.simplesort
        chain = chain.simplesort(rule.local.simplesort, rule.local.simplesortDesc)

      if rule.local.limit
        chain = chain.limit(rule.local.limit)

      @records = @records.concat(chain.data())

    @records = uniq @records.concat(compact(@records.map (o) -> o.parent()))
    @records = orderBy @records, 'positionKey'
    eventIds = @records.map (event) -> event.id

    orphans = @records.filter (event) ->
      event.parentId == null || !eventIds.includes(event.parentId)

    eventsByParentId = {}
    @records.forEach (event) =>
      eventsByParentId[event.parentId] = (eventsByParentId[event.parentId] || []).concat([event])

    nest = (records) ->
      r = records.map (event) ->
        event: event
        children: (eventsByParentId[event.id] && nest(eventsByParentId[event.id])) || []
        eventable: event.model()
      # orderBy r, 'positionKey'

    @collection = nest(orphans)

    @addMetaData(@collection)

    EventBus.$emit('collectionUpdated', @discussion.id)

    @collection

  addMetaData: (collection) ->
    positions = collection.map (e) -> e.event.position
    ranges = RangeSet.arrayToRanges(positions)
    parentExists = collection[0] && collection[0].event && collection[0].event.parent()
    lastPosition = (parentExists && (collection[0].event.parent().childCount)) || 0


    collection.forEach (obj) =>
      obj.isUnread = @isUnread(obj.event)
      isFirstInRange = some(ranges, (range) -> range[0] == obj.event.position)
      isLastInLastRange = last(ranges)[1] == obj.event.position
      missingEarlier = parentExists && (obj.event.position != 1 && isFirstInRange)
      obj.missingEarlierCount = 0
      if missingEarlier
        lastPos = 1
        val = 0
        ranges.forEach (range) ->
          if range[0] == obj.event.position
            val = (obj.event.position - lastPos)
          else
            lastPos = range[1]
        obj.missingEarlierCount = val

      missingAfter = lastPosition != 0 && isLastInLastRange && (obj.event.position != lastPosition)
      obj.missingAfterCount = (missingAfter && lastPosition - last(ranges)[1]) || 0
      obj.missingChildCount = obj.event.childCount - obj.children.length

      @addMetaData(obj.children) if obj.children.length
