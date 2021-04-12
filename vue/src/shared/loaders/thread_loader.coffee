import Records from '@/shared/services/records'
import { max, isNumber, uniq, compact, orderBy, camelCase, forEach, isObject, sortedUniq, sortBy, without, map } from 'lodash'
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
    @unreadIds = []
    @focusAttrs = {}
    @visibleKeys = {}
    @collapsed = Vue.observable({})
    @loading = false
    @padding = 20

  setVisible: (isVisible, event) ->
    event.markAsRead() unless @visibleKeys.hasOwnProperty(event.positionKey)
    @visibleKeys[event.positionKey] = isVisible
    EventBus.$emit('visibleKeys', Object.keys(@visibleKeys).filter((key) => @visibleKeys[key]).sort())

  collapse: (event) ->
    Object.keys(@visibleKeys).forEach (key) =>
      @visibleKeys[key] = false if key.startsWith(event.positionKey)
    Vue.set(@collapsed, event.id, true)

  expand: (event) ->
    Vue.set(@collapsed, event.id, false)

  jumpToEarliest: ->
    @reset()
    @addLoadOldestFirstRule()
    @fetch()

  jumpToLatest: ->
    @reset()
    @addLoadNewestFirstRule()
    @fetch()

  jumpToUnread: ->
    @reset()
    @addLoadUnreadRule()
    @fetch()

  jumpToSequenceId: (id) ->
    @reset()
    @addLoadSequenceIdRule(id)
    @fetch()


  loadEverything: ->
    @loading = true
    @titleKey = 'strand_nav.whole_thread'
    @addRule
      local:
        find:
          discussionId: @discussion.id
      remote:
        discussion_id: @discussion.id
        per: 1000

  loadChildren: (event) ->
    @loading = 'children'+event.id
    if event.kind == "new_discussion"
      @addRule
        name: "load discussion children"
        local:
          find:
            discussionId: @discussion.id
          simplesort: 'id'
          limit: @padding
        remote:
          discussion_id: @discussion.id
          order_by: 'position_key'
          per: @padding
    else
      @addRule
        name: "load children (prefix #{event.positionKey})"
        local:
          find:
            discussionId: @discussion.id
            positionKey: {'$regex': "^#{event.positionKey}"}
          simplesort: 'positionKey'
          limit: @padding
        remote:
          discussion_id: @discussion.id
          position_key_sw: event.positionKey
          depth_gt: event.depth
          order_by: 'position_key'
          per: @padding

  autoLoadAfter: (event) ->
    @loadAfter(event) if event.depth == 1

  autoLoadBefore: (event) ->
    @loadBefore(event) if event.depth == 1

  loadAfter: (event) ->
    # keys = event.positionKey.split('-')
    # num = parseInt(keys[keys.length - 1]) + 1
    # key = "0".repeat(5 - (""+num).length) + num
    # keys[keys.length - 1] = key
    # positionKey = keys.join('-')
    # positionKeyPrefix = event.positionKey.split('-').slice(0,-1).join('-')
    # positionKeyPrefix = undefined if keys.length == 1
    positionKeyPrefix = event.positionKey.split('-').slice(0,-1).join('-')
    positionKey = event.positionKey

    @addRule
      name: "load after (prefix #{positionKeyPrefix})"
      local:
        find:
          discussionId: @discussion.id
          positionKey:
            $jgt: positionKey
            $regex: (positionKeyPrefix && "^#{positionKeyPrefix}") || undefined
        simplesort: 'id'
        limit: @padding
      remote:
        discussion_id: @discussion.id
        position_key_gt: positionKey
        position_key_sw: positionKeyPrefix || null
        order_by: 'position_key'
        per: @padding

  loadBefore: (event) ->
    @loading = 'before'+event.id
    positionKeyPrefix = event.positionKey.split('-').slice(0,-1).join('-')

    @addRule
      name: "load before (prefix #{positionKeyPrefix})"
      local:
        find:
          discussionId: @discussion.id
          positionKey:
            $jlt: event.positionKey
            $regex: (positionKeyPrefix && "^#{positionKeyPrefix}") || undefined
        simplesort: 'sequenceId'
        simplesortDesc: true
        limit: @padding
      remote:
        discussion_id: @discussion.id
        position_key_lt: event.positionKey
        position_key_sw: positionKeyPrefix || null
        order_by: 'position_key'
        order_desc: 1
        per: @padding

  addLoadCommentRule: (commentId) ->
    @titleKey = 'strand_nav.from_comment'
    @rules.push
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

  addLoadPinnedRule: ->
    @titleKey = 'strand_nav.all_pinned'
    @rules.push
      name: "all pinned events"
      local:
        find:
          discussionId: @discussion.id
          pinned: true
        # position: {$gte: position}
      remote:
        discussion_id: @discussion.id
        pinned: true
        per: 200

  addLoadPositionRule: (position) ->
    @rules.push
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
    @rules.push
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

    @rules.push
      name: "positionKey rollback"
      local:
        find:
          discussionId: @discussion.id
          positionKey: {$lt: positionKey}
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
    @titleKey = 'strand_nav.from_sequence_id'
    @rules.push
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

  addLoadNewestRule: () ->
    @titleKey = 'strand_nav.newest_first'
    @rules.push
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
    @rules.push
      name: 'context'
      local:
        find:
          id: @discussion.createdEvent().id

  addLoadOldestRule: ->
    @titleKey = 'strand_nav.oldest_first'
    @rules.push
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
    @titleKey = 'strand_nav.unread'
    if @discussion.updatedAt > @discussion.lastReadAt
      @rules.push
        name: "context updated"
        local:
          find:
            id: @discussion.createdEvent().id

    # I don't think we need this..
    # @rules.push
    #   name: {path: "strand_nav.new_to_you"}
    #   local:
    #     find:
    #       discussionId: @discussion.id
    #       sequenceId: {$or: @discussion.unreadRanges().map((r) -> {$between: r} )}
    #     limit: @padding
    #   remote:
    #     discussion_id: @discussion.id
    #     unread: true
    #     order_by: "sequence_id"
    #     per: @padding

    # padding around new to you
    id = max([@discussion.firstUnreadSequenceId() - parseInt(@padding/2), @discussion.firstSequenceId()])
    @rules.push
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
    @rules.push(rule)
    params = Object.assign {}, rule.remote, {exclude_types: 'group discussion'}
    Records.events.fetch(params: params).finally => @loading = false
    # @updateCollection()
    # Records.events.fetch(params: params).then (data) => @updateCollection()

  fetch:  ->
    promises = @rules.filter((rule) -> rule.remote).map (rule) =>
      params = Object.assign {}, rule.remote, {exclude_types: 'group discussion'}
      Records.events.fetch(params: params)
    # console.log promises
    Promise.all(promises).finally => @loading = false

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
      @unreadIds.push(event.sequenceId) if !RangeSet.includesValue(@discussion.readRanges, event.sequenceId)

    nest = (records) ->
      r = records.map (event) ->
        {event: event, children: (eventsByParentId[event.id] && nest(eventsByParentId[event.id])) || []}
      # orderBy r, 'positionKey'

    @collection = nest(orphans)

    # console.log 'rules', rules.length, rules
    # console.log 'eventIds', eventIds.length, eventIds
    # console.log 'orphans', orphans.length, orphans
    # console.log 'collection', @collection.length, @collection

    @collection
